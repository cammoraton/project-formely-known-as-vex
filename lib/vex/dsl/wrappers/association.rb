module Vex
  module Dsl
    module Wrappers
      module Association
        # Constructs queries and filters them against Assignments, or passes through to cache
        class Wrapper
          def initialize(object)
            @object = object
          end
          
          # We're really an array, we swear
          def method_missing(m, *args, &block) 
            self.to_a.send m, *args, &block
          end
          
          def to_a
            unless @object.has_cache?
              @associations ||= run_queries
            else
              @object.cache
            end
          end
                
          def reload
            # When we call reload we always execute our queries
            @query_depth  = calculate_query_depth
            @queries      = construct_queries
            @associations = run_queries
            return @associations
          end 
          
          def query_depth
            @query_depth ||= calculate_query_depth
          end
                    
          def queries
            @queries ||= construct_queries
          end
    
          # Sugar methods
          def by_type(type, include_dependencies = false)
            unless include_dependencies
              self.to_a.select{ |a| a if (a["type"].to_s == type.to_s and 
                                         (a["dependency_only"].nil? or a["dependency_only"] == false)) }
            else
              self.to_a.select{ |a| a if a["type"].to_s == type.to_s }
            end
          end  
          
          def by_types(array, include_dependencies = false)
            unless include_dependencies
              self.to_a.select{ |a| a if (array.include?(a["type"]) and 
                                         (a["dependency_only"].nil? or a["dependency_only"] == false))}
            else
              self.to_a.select{ |a| a if array.include?(a["type"]) }
            end
          end
          
          private
          # Currently maxes out at a depth of two.  Need to come up with a good way to figure this out without getting overzealous
          def calculate_query_depth
            query_depth = 0
            
            @object.vex_assignments.keys.select{ |a| a unless @object.vex_assignments[a].nil? or @object.vex_assignments[a][:through].nil? }.each do |key|
              query_depth = 1 if query_depth < 1
              eval = @object.vex_assignments[key][:through]
              if eval.is_a? Array
                eval.each do |through|
                  unless @object.vex_assignments[through].nil? or @object.vex_assignments[through][:through].nil?
                    query_depth = 2 if query_depth < 2
                    test = @object.vex_assignments[through][:through]
                  end
                end
              end
            end
            return query_depth
          end
          
          def construct_queries
            queries = Hash.new
            # Need to pass this through the class we're mixed in with or else it will default to the module
            query_interface = @object.class.const_get("Configuration")
            
            # Now construct and execute the queries
            queries[0]  = query_interface.where(:_id => { :$in => @object.assignment_ids }).fields(:name, :_id, :_type, :assignment_ids, :cache).all
            # First level of inheritance is special
            unless self.query_depth < 1
              queries[1] = query_interface.where({ :$and => [{ :assignment_ids => {:$in => @object.assignment_ids}},
                                                           { :_id => { :$nin => @object.assignment_ids + [ @object._id ] }}]}).fields(:name, :_id, :_type, :assignment_ids, :cache).all
              # Now go through through the rest
              unless self.query_depth < 2
                (2..self.query_depth).each do |depth|
                  current_ids = [ @object._id ] 
                  (0..depth-1).each do |current|
                    current_ids = (current_ids + queries[current].map{|a| a._id}).uniq
                  end
                  assign_ids = Array.new
                  queries[depth-1].each do |assign|
                    assign_ids = (assign_ids + assign.assignment_ids).uniq
                  end
                  queries[depth] = query_interface.where({ :$and => [{:assignment_ids => {:$in => assign_ids}},
                                                                   {:_id => {:$nin => current_ids }}]}).fields(:name, :_id, :_type, :assignment_ids, :cache).all
                end
              end
            end 
            return queries
          end
          
          def parse_query(query, check)
            ids = Array.new
            check.each do |build|
              ids = (ids + [ build["id"] ]).uniq
            end
            query.each do |evaluate|
              inherited_ids = Array.new
              check.select{ |a| a if evaluate.assignment_ids.include?(BSON::ObjectId.from_string(a["id"])) }.each do |inherited|
                inherited_ids = (inherited_ids + [ inherited["id"] ]).uniq
              end
            
              next if inherited_ids.empty?
            
              cache_check = @associations.select{ |a| a if a["id"].to_s == evaluate._id.to_s }  
              if cache_check.empty?
                inherited_ids = inherited_ids.first unless inherited_ids.count > 1
                @associations.push({ "id"     => evaluate._id.to_s, 
                                     "type"   => evaluate._type.to_s, 
                                     "name"   => evaluate.name, 
                                     "source" => inherited_ids })
              else
                cache_check.each do |update|
                  if update["source"].is_a? Array
                    inherited_ids = ( inherited_ids + update["source"]).uniq
                  else
                    inherited_ids = ( inherited_ids + [ update["source"] ]).uniq
                  end
                  inherited_ids = inherited_ids.first unless inherited_ids.count > 1
                  update["source"] = inherited_ids
                end
              end
            end
          end
          
          def run_queries
            @associations = Array.new
          
            assignments = self.queries
            query_depth = assignments.keys.count - 1
          
            @object.vex_assignments.keys.each do |key|
              klass = @object.class.const_get(key.to_s.singularize.camelize)
              assignments[0].select{ |a| a if a._type.to_s == klass.to_s}.each do |eval|
                @associations.push({ "id"     => eval._id.to_s, 
                                     "type"   => eval._type.to_s, 
                                     "name"   => eval.name, 
                                     "source" => @object._id.to_s })
              end
            end
          
            unless query_depth < 1
              @object.vex_assignments.keys.select{ |a| a unless @object.vex_assignments[a][:through].nil? }.each do |key|
                klass = @object.class.const_get(key.to_s.singularize.camelize) 
                eval = @object.vex_assignments[key][:through]
                if eval.is_a? Array
                  eval.each do |evaluate|
                    eval_klass = @object.class.const_get(evaluate.to_s.singularize.camelize)
                    parse_query(assignments[1].select{ |a| a if a._type.to_s == klass.to_s }, 
                                @associations.select{ |a| a if a["type"] == eval_klass.to_s})
                  end
                else
                  eval_klass = @object.class.const_get(eval.to_s.singularize.camelize)
                  parse_query(assignments[1].select{ |a| a if a._type.to_s == klass.to_s }, 
                              @associations.select{ |a| a if a["type"] == eval_klass.to_s} )
                end
              end
              unless query_depth < 2
                # We need to iterate through our relationships
                (2..query_depth).each do |depth|
                  @object.vex_assignments.keys.select{ |a| a unless @object.vex_assignments[a][:through].nil? }.each do |key|
                    klass = @object.class.const_get(key.to_s.singularize.camelize) 
                    eval = @object.vex_assignments[key][:through] 
                    if eval.is_a? Array
                      eval.each do |evaluate|
                        eval_klass = @object.class.const_get(evaluate.to_s.singularize.camelize)
                        parse_query(assignments[depth].select{ |a| a if a._type.to_s == klass.to_s }, 
                                    @associations.select{ |a| a if a["type"] == eval_klass.to_s})
                      end
                    else
                      eval_klass = @object.class.const_get(eval.to_s.singularize.camelize)
                      parse_query(assignments[depth].select{ |a| a if a._type.to_s == klass.to_s }, 
                                  @associations.select{ |a| a if a["type"] == eval_klass.to_s} )
                    
                    end
                  end
                end
              end
            end
            
            # For now only parse in full dependencies if caching is on.
            if @object.has_cache?
              all_items = []
              (0..query_depth).each do |iterate|
                all_items = (all_items + assignments[iterate]).uniq  
              end
              all_items.select{ |a| a if @associations.map{|b| b["id"]}.include?(a._id.to_s)}.each do |parse|
                if @object.vex_dependencies["triggers"].include?(parse._type.to_s.downcase.pluralize.to_sym)
                  deps = parse.vex_associations.by_types(parse.vex_dependencies["triggers"].map{|a| a.to_s.singularize.camelize}, true)
                  deps.select{ |a| a if !@associations.map{|b| b["id"]}.include?(a["id"]) and a["id"] != @object._id.to_s }.each do |dependency|
                    @associations.push({ "id" => dependency["id"],
                                         "type" => dependency["type"],
                                         "name" => dependency["name"],
                                         "source" => dependency["source"],
                                         "dependency_only" => true})
                  end
                end 
                if @object.vex_dependencies["triggered_by"].include?(parse._type.to_s.downcase.pluralize.to_sym)
                  deps = parse.vex_associations.by_types(parse.vex_dependencies["triggered_by"].map{|a| a.to_s.singularize.camelize}, true)
                  deps.select{ |a| a if !@associations.map{|b| b["id"]}.include?(a["id"]) and a["id"] != @object._id.to_s }.each do |dependency|
                    @associations.push({ "id" => dependency["id"],
                                         "type" => dependency["type"],
                                         "name" => dependency["name"],
                                         "source" => dependency["source"],
                                         "dependency_only" => true})
                  end
                end
              end
            end
            return @associations
          end
        end
      end
    end
  end
end
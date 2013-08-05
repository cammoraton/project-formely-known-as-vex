module Vex
  module Dsl
    module Configuration
      module Cache
        extend ActiveSupport::Concern
      
        module ClassMethods
          def vex_has_cache
            @vex_cache ||= false
          end
          
          def has_cache
            @vex_cache = true
            key         :cache, Array
            
            before_save :update_cache
          end
        end
        
        def self.included(base)
          base.extend ClassMethods
        end
        
        def has_cache?
          self.class.vex_has_cache
        end
        
        private
        def cache_queries
          queries = Hash.new
          # Need to pass this through the class we're mixed in with or else it will default to the module
          query_interface = self.class.const_get("Configuration")
          query_depth = 0
          # Figure out how many levels of nesting we need to satisfy dependencies and assignments
          self.vex_assignments.keys.each do |key|
            unless self.vex_assignments[key].nil? or self.vex_assignments[key][:through].nil?
              query_depth = 1 if query_depth < 1
              eval = self.vex_assignments[key][:through]
              if eval.is_a? Array
                eval.each do |through|
                  unless self.vex_assignments[through].nil? or self.vex_assignments[through][:through].nil?
                    query_depth = 2 if query_depth < 2
                  end
                end
              end
            end
          end
          logger.debug("[DEBUG] - update_cache: Calculated query depth of #{query_depth}")
          
          # Now construct and execute the queries
          queries[0]  = query_interface.where(:_id => { :$in => self.assignment_ids }).fields(:name, :_id, :_type, :assignment_ids, :cache).all
          logger.debug("[DEBUG] - update_cache: Executed query for depth 0, found #{queries[0].count} records")
          # First level of inheritance is special
          unless query_depth < 1
            queries[1] = query_interface.where({ :$and => [{ :assignment_ids => {:$in => self.assignment_ids}},
                                                           { :_id => { :$nin => self.assignment_ids + [ self._id ] }}]}).fields(:name, :_id, :_type, :assignment_ids, :cache).all
            logger.debug("[DEBUG] - update_cache: Executed query for depth 1, found #{queries[1].count} records")
            # Now go through through the rest
            unless query_depth < 2
              (2..query_depth).each do |depth|
                current_ids = [ self._id ] 
                (0..depth-1).each do |current|
                  current_ids = (current_ids + queries[current].map{|a| a._id}).uniq
                end
                assign_ids = Array.new
                queries[depth-1].each do |assign|
                  assign_ids = (assign_ids + assign.assignment_ids).uniq
                end
                queries[depth] = query_interface.where({ :$and => [{:assignment_ids => {:$in => assign_ids}},
                                                                   {:_id => {:$nin => current_ids }}]}).fields(:name, :_id, :_type, :assignment_ids, :cache).all
                logger.debug("[DEBUG] - update_cache: Executed query for depth #{depth}, found #{queries[depth].count} records")
              end
            end
          end 
          return queries
        end
        
        def parse_cache_query_results(query, check)
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
            
            cache_check = self.cache.select{ |a| a if a["id"].to_s == evaluate._id.to_s }  
            if cache_check.empty?
              inherited_ids = inherited_ids.first unless inherited_ids.count > 1
              self.cache.push({ "id" => evaluate._id.to_s, 
                                "type" => evaluate._type.to_s, 
                                "name" => evaluate.name, 
                                "source" => inherited_ids, 
                                "dependency_only" => false })
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
        
        def update_cache
          logger.info("[INFO]  - update_cache: Updating cache for object id: #{self._id}")
          old_cache = self.cache.dup  # Duplicate cache
          logger.debug("[DEBUG] - update_cache: old cache is #{self.cache.to_json}")
          self.cache = Array.new      # Clear cache
          
          assignments = cache_queries
          query_depth = assignments.keys.count - 1
          
          logger.debug("[DEBUG] - update_cache: Updating cache for direct assignments")
          self.vex_assignments.keys.each do |key|
            klass = self.class.const_get(key.to_s.singularize.camelize)
            assignments[0].select{ |a| a if a._type.to_s == klass.to_s}.each do |eval|
              self.cache.push({ "id" => eval._id.to_s, 
                                "type" => eval._type.to_s, 
                                "name" => eval.name, 
                                "source" => self._id.to_s, 
                                "dependency_only" => false })
            end
          end
          
          unless query_depth < 1
            logger.debug("[DEBUG] - update_cache: Updating cache for depth level 1 assignments")
            self.vex_assignments.keys.select{ |a| a unless self.vex_assignments[a][:through].nil? }.each do |key|
              klass = self.class.const_get(key.to_s.singularize.camelize) 
              eval = self.vex_assignments[key][:through]
              if eval.is_a? Array
                eval.each do |evaluate|
                  eval_klass = self.class.const_get(evaluate.to_s.singularize.camelize)
                  parse_cache_query_results(assignments[1].select{ |a| a if a.type.to_s == klass.to_s }, 
                                            self.cache.select{ |a| a if a["type"] == eval_klass.to_s})
                end
              else
                eval_klass = self.class.const_get(eval.to_s.singularize.camelize)
                parse_cache_query_results(assignments[1].select{ |a| a if a.type.to_s == klass.to_s }, 
                                          self.cache.select{ |a| a if a["type"] == eval_klass.to_s} )
              end
            end
            unless query_depth < 2
              # We need to iterate through our relationships
              (2..query_depth).each do |depth|
                logger.debug("[DEBUG] - update_cache: Updating cache for depth level #{depth} assignments")
                self.vex_assignments.keys.select{ |a| a unless self.vex_assignments[a][:through].nil? }.each do |key|
                  klass = self.class.const_get(key.to_s.singularize.camelize) 
                  eval = self.vex_assignments[key][:through] 
                  if eval.is_a? Array
                    eval.each do |evaluate|
                      eval_klass = self.class.const_get(evaluate.to_s.singularize.camelize)
                      parse_cache_query_results(assignments[depth].select{ |a| a if a.type.to_s == klass.to_s }, 
                                                self.cache.select{ |a| a if a["type"] == eval_klass.to_s})
                    end
                  else
                      eval_klass = self.class.const_get(eval.to_s.singularize.camelize)
                      parse_cache_query_results(assignments[depth].select{ |a| a if a.type.to_s == klass.to_s }, 
                                                self.cache.select{ |a| a if a["type"] == eval_klass.to_s} )
                    
                  end
                end
              end
            end
          end
          
          logger.debug("[DEBUG] - update_cache: cache updated, is now #{self.cache.to_json}")  
          cascade = self.cache.map{|a| a["id"]} - old_cache.map{|a| a["id"]}
          
          logger.debug("[DEBUG] - update_cache: new items #{cascade.to_json}")  
        end
      end
    end
  end
end

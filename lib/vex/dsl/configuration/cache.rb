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
        # This is one hell of a method.
        def update_cache
          logger.debug("[DEBUG] - update_cache: Updating cache for object id: #{self._id}")
          old_cache = self.cache.dup  # Duplicate cache
          self.cache = Array.new      # Clear cache
          
          # Set up our query results container
          assignments = Hash.new
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
          assignments[0]  = Configuration.where(:_id => { :$in => self.assignment_ids }).fields(:name, :_id, :_type, :assignment_ids).all
          logger.debug("[DEBUG] - update_cache: Executed query for depth 0, found #{assignments[0].count} records")
          # First level of inheritance is special
          unless query_depth < 1
            assignments[1] = Configuration.where({ :$and => [{ :assignment_ids => {:$in => self.assignment_ids}},
                                                             { :_id => { :$nin => self.assignment_ids }}]}).fields(:name, :_id, :_type, :assignment_ids).all
            logger.debug("[DEBUG] - update_cache: Executed query for depth 1, found #{assignments[1].count} records")
            # Now go through through the rest
            unless query_depth < 2
            (2..query_depth).each do |depth|
                current_ids = Array.new
                (0..depth-1).each do |current|
                  current_ids = (current_ids + assignments[current].map{|a| a._id}).uniq
                end
                assignments[depth] = Configuration.where({ :$and => [{:assignment_ids => {:$in => assignments[depth-1].map{|a| a.assignment_ids }}},
                                                                     {:_id => {:$nin => current_ids }}]}).fields(:name, :_id, :_type, :assignment_ids).all
                logger.debug("[DEBUG] - update_cache: Executed query for depth #{depth}, found #{assignments[depth].count} records")
              end
            end
          end 
          
          logger.debug("[DEBUG] - update_cache: Updating cache for direct assignments")
          self.vex_assignments.keys.each do |key|
            klass = self.class.const_get(key.to_s.singularize.camelize)
            logger.debug("[DEBUG] - update_cache: Updating cache for direct assignments, processing class #{key.to_s.singularize.camelize}, #{assignments[0].select{ |a| a if a._type == klass}.count} records")
            assignments[0].select{ |a| a if a._type == klass}.each do |eval|
              self.cache.push({ "id" => eval._id.to_s, "type" => eval._type.to_s, "name" => eval.name, "source" => self._id.to_s, "dependency_only" => false })
            end
          end
            
          #cascade = self.cache.map{|a| a["id"]} - old_cache.map{|a| a["id"]}
        end
      end
    end
  end
end
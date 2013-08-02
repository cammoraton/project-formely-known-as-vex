module Vex
  module Dsl
    module Configuration
      module Cache
        extend ActiveSupport::Concern
      
        module ClassMethods
          def vex_assignment_cache
            @vex_assignment_cache ||= false
          end
          
          def vex_dependency_cache
            @vex_dependency_cache ||= false
          end
          
          def caches_associations
            @vex_assignment_cache = true
            before_save :cache_assignments
            
            module_eval <<-end_eval
              def assignment_cache
                @assignment_cache ||= Vex::Dsl::Wrappers::Cache::Assignments.new(self)
              end
              
              def assignment_cache=(val)
                self.cache["assignments"] = val
              end
              
              def assignment_sources_cache
                @sources_cache ||= Vex::Dsl::Wrappers::Cache::Sources.new(self)
              end
              
              def assignment_sources_cache=(val)
                self.cache["sources"] = val
              end
            end_eval
          end
          
          def caches_dependencies
            @vex_dependency_cache = true
            before_save :cache_dependencies
            
            module_eval <<-end_eval
              def dependency_cache
                @dependency_cache ||= Vex::Dsl::Wrappers::Cache::Dependencies.new(self)
              end
              def dependency_cache=(val)
                self.cache["dependencies"] = val
              end
            end_eval
          end
        end
        
        def self.included(base)
          base.extend ClassMethods
        end
        
        def caches_assignments?
          self.class.vex_assignment_cache
        end
        
        def caches_dependencies?
          self.class.vex_dependency_cache
        end
        
        def cache
          self.metadata["cache"] ||= {}
        end
        
        private
        def cache_assignments
          # No idea why this breaks if we don't do this, but whatever, logging is fine.
          logger.debug("[DEBUG] - Updating assignment cache for object id: #{self._id}")
          logger.debug("[DEBUG] --- Assigns at start: #{self.assignment_cache.to_h.to_json}")
          logger.debug("[DEBUG] --- Sources at start: #{self.assignment_sources_cache.to_h.to_json}")
          
          self.assignment_cache = Hash.new         # Clear the cache
          self.assignment_sources_cache = Hash.new # Clear the cache
          self.vex_assignments.keys.each do |key|
            self.assignment_cache[key] = []
            self.assignment_sources_cache[key] = Hash.new
            self.send(key).reload
            eval = self.send(key).to_a
            unless eval.empty?
              self.assignment_cache[key] = eval.map{|a| { :id => a._id.to_s, :name => a.name } }
              eval.each do |item|
                associated = item.associated_via(self)
                unless associated.nil?
                  self.assignment_sources_cache[key][item._id.to_s] = associated._id
                else
                  self.assignment_sources_cache[key][item._id.to_s] = nil
                end
              end
            end
          end
          logger.debug("[DEBUG] - Updated assignment cache for object id: #{self._id}")
          logger.debug("[DEBUG] --- Assigns at end: #{self.assignment_cache.to_h.to_json}")
          logger.debug("[DEBUG] --- Sources at end: #{self.assignment_sources_cache.to_h.to_json}")
          return nil
        end
        
        def parse_dependencies(array, dependency_type = nil)
          return if array.nil? or array.empty?
          return if dependency_type.nil?
          array.each do |id|
            logger.debug("[DEBUG] --- Processing id #{id}")
            type = self.assignment_cache.type_by_id(id)
            eval = self.send(type)
            unless eval.nil?
              logger.debug("[DEBUG] ----- Looking up id #{id}")
              eval = eval.find_by_id(id)
              unless eval.nil?
                # Obviously anything we're associated with is associated with us, so...
                local_ids = self.dependencies.flatten_to_ids(self.vex_dependencies[dependency_type]) + [ self._id.to_s ]
                foreign_ids = eval.dependencies.flatten_to_ids(eval.vex_dependencies[dependency_type])
                new_ids = (foreign_ids - local_ids)
                unless new_ids.empty?
                  logger.debug("[DEBUG] ----- New ids #{new_ids.join(', ')} found for id #{id}")
                  self.dependency_cache[dependency_type][id] = Array.new unless self.dependency_cache[dependency_type].keys.include?(id)
                  new_ids.each do |nid|
                    push = eval.dependency_cache.find_by_id(nid, eval.vex_dependencies[dependency_type])
                    logger.debug("[DEBUG] ----- Lookup for #{nid} is #{eval.dependency_cache.find_by_id(nid, eval.vex_dependencies[dependency_type]).inspect}")
                    logger.debug("[DEBUG] ----- Pushing #{push.to_json} into array for id: #{id}")
                    self.dependency_cache[dependency_type][id].push(push) unless push.nil?
                  end
                else
                  logger.debug("[DEBUG] ----- No new ids found for id #{id}")
                end
              end
            end
          end
        end
        
        def cache_dependencies
          logger.debug("[DEBUG] - Updating dependency cache for object id: #{self._id}")
          logger.debug("[DEBUG] --- State at start: #{self.dependency_cache.to_h.to_json}")
          self.dependency_cache = Hash.new
          self.dependency_cache["triggers"]     = Hash.new
          self.dependency_cache["triggered_by"] = Hash.new
          locals       = self.dependencies.flatten_to_ids(self.vex_assignments.keys)
          triggers     = self.dependencies.flatten_to_ids(self.vex_dependencies["triggers"])
          triggered_by = self.dependencies.flatten_to_ids(self.vex_dependencies["triggered_by"])
          logger.debug("[DEBUG] - Checking locality of ids: #{locals.join(', ')} ")
          local_locals = locals.select{ |a| a if self.assignment_sources_cache.source_by_id(a).to_s == self._id.to_s }
          locals = locals - local_locals
          logger.debug("[DEBUG] - Parsing directly sourced ids #{local_locals.join(', ')}")
          parse = local_locals.select{|a| a if triggers.include?(a) }
          logger.debug("[DEBUG] --- Parsing triggers - ids #{parse.join(', ')}")
          parse_dependencies(parse, "triggers")
          parse = local_locals.select{|a| a if triggers.include?(a) }
          logger.debug("[DEBUG] --- Parsing triggered_by - ids #{parse.join(', ')}")
          parse_dependencies(parse, "triggered_by")
          logger.debug("[DEBUG] - Parsing indirectly sourced ids #{locals.join(', ')}")
          parse = locals.select{|a| a if triggers.include?(a) }
          logger.debug("[DEBUG] --- Parsing triggers - ids #{parse.join(', ')}")
          parse_dependencies(parse, "triggers")
          parse = locals.select{|a| a if triggers.include?(a) }
          logger.debug("[DEBUG] --- Parsing triggered_by - ids #{parse.join(', ')}")
          parse_dependencies(parse, "triggered_by")
          logger.debug("[DEBUG] - Updated dependency cache for object id: #{self._id}")
          logger.debug("[DEBUG] --- State at end: #{self.dependency_cache.to_h.to_json}")
          return nil
        end
       
      end
    end
  end
end
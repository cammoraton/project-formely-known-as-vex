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
        def update_cache
          logger.info("[INFO]  - update_cache: Updating cache for object id: #{self._id}")
          logger.info("[DEBUG] - update cache: Number of queries is #{self.vex_associations.query_depth}")
          old_cache = self.cache.dup  # Duplicate cache
          logger.debug("[DEBUG] - update_cache: old cache is #{self.cache.to_json}")
          self.cache = self.vex_associations.reload # Force a requery
          logger.debug("[DEBUG] - update_cache: cache updated, is now #{self.cache.to_json}")  
          
          cascade = self.cache.map{|a| a["id"]} - old_cache.map{|a| a["id"]}
          logger.debug("[DEBUG] - update_cache: new items #{cascade.to_json}")  
        end
      end
    end
  end
end

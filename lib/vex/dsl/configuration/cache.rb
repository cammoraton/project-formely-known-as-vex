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
            after_save  :cascade_save
          end
        end
        
        def self.included(base)
          base.extend ClassMethods
        end
        
        def cascade
          @cascade ||= []
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
          
          cascade_save    = self.cache.map{|a| a["id"]} - old_cache.map{|a| a["id"]}
          cascade_deleted = old_cache.map{|a| a["id"]} - self.cache.map{|a| a["id"]}
          # Combine and remove any direct associations( fixup_assignments will take care of those)
          @cascade = ((cascade_save + cascade_deleted) - 
                    self.vex_associations.to_a.select{|a| a["id"] if a["source"].to_s == self._id.to_s}).uniq
          logger.debug("[DEBUG] - update_cache: new or deleted ids #{@cascade.to_json}")  
        end
        
        def cascade_save
          ids = self.cascade.map{|a| BSON::ObjectId(a)}
          query_wrapper = self.class.const_get("Configuration")
          query_wrapper.where(:_id => {:$in => ids }).all.each do |cascade|
            cascade.touch; cascade.save; cascade.reload
          end
          @cascade = []
        end
      end
    end
  end
end

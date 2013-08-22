module Vex
  module Dsl
    module Configuration
      module Cache
        extend ActiveSupport::Concern
      
        module ClassMethods
          def vex_cached
            @vex_cached ||= false
          end
          
          def has_cache
            @vex_cached = true
            key         :cache, Array
            
            before_save :update_cache
            after_save  :cascade_save
          end
        end
        
        def self.included(base)
          base.extend ClassMethods
        end
        
        def cascade_pending
          @cascade_pending ||= []
        end
        
        def cascade_pending=(val)
          @cascade_pending = val
        end
        
        def cascaded
          @cascaded ||= []
        end
        
        def cascaded=(val)
          @cascaded = val
        end
        
        def has_cache?
          self.class.vex_cached
        end
        
        private
        def update_cache
          logger.info("[INFO]  - update_cache: Updating cache for object id: #{self._id}")
          logger.info("[DEBUG] - update cache: Number of queries is #{self.vex_associations.query_depth}")
          old_cache = self.cache.dup  # Duplicate cache
          logger.debug("[DEBUG] - update_cache: old cache is #{self.cache.to_json}")
          self.cache = self.vex_associations.reload # Force a requery
          logger.debug("[DEBUG] - update_cache: cache updated, is now #{self.cache.to_json}")  
          
          cascade_save    = self.cache.select{|a| a if (a["dependency_only"].nil? or a["dependency_only"] == false)}.map{|a| a["id"]} - 
                             old_cache.select{|a| a if (a["dependency_only"].nil? or a["dependency_only"] == false)}.map{|a| a["id"]}
          cascade_deleted =  old_cache.select{|a| a if (a["dependency_only"].nil? or a["dependency_only"] == false)}.map{|a| a["id"]} - 
                            self.cache.select{|a| a if (a["dependency_only"].nil? or a["dependency_only"] == false)}.map{|a| a["id"]}
          # Combine and remove any direct associations( fixup_assignments will take care of those)
          self.cascade_pending = ((cascade_save + cascade_deleted) - 
                                  self.vex_associations.to_a.select{|a| a if a["source"].to_s == self._id.to_s}.map{|a| a["id"]}).uniq
                            
          logger.debug("[DEBUG] - update_cache: new or deleted ids #{@cascade.to_json}")        
          # Now we need to add in anything that needs saved because sourcing has changed.
          self.cache.select{|a| a if (a["dependency_only"].nil? or a["dependency_only"] == false)}.map{|a| a["id"]}.each do |source|
            this_source = self.cache.select{|a| a["source"] if a["id"] == source }
            new_source  = old_cache.select{|a| a["source"] if a["id"] == source }
            unless this_source.nil? or this_source.empty? or new_source.nil? or new_source.empty?
              if this_source.first != new_source.first
                self.cascade_pending.push(source) unless self.cascade_pending.include?(source)
              end
            end
          end
          
          logger.debug("[DEBUG] - update_cache: after adding in changed sources, cascade equals #{@cascade.to_json}")  
        end
        
        def cascade_save
          ids = (self.cascade_pending - self.cascaded).uniq.map{|a| BSON::ObjectId(a)}
          query_wrapper = self.class.const_get("Configuration")
          query_wrapper.where(:_id => {:$in => ids }).all.each do |cascade|
            cascade.cascaded = (self.cascade_pending + self.cascaded).uniq
            cascade.touch; cascade.save; cascade.reload
          end
          self.cascade_pending = []
          self.cascaded = []
        end
      end
    end
  end
end

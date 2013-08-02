module Vex
  module Dsl
    module Wrappers
      module Cache
        class Sources
          def initialize(parent)
            @parent = parent
          end
          
          def method_missing(m, *args, &block) 
            self.to_h.send m, *args, &block
          end
          
          def to_h
            @parent.cache["sources"]
          end
          
          def source_by_id(id)
            self.to_h.keys.each do |key| 
              unless self.to_h[key].nil? or self.to_h[key].empty?
                return self.to_h[key][id] unless self.to_h[key][id].nil?
              end
            end
            return nil
          end
          
        end
      end
    end
  end
end
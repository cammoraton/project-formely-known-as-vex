module Vex
  module Dsl
    module Wrappers
      module Cache
        class Assignments
          def initialize(parent)
            @parent = parent
          end
          
          def method_missing(m, *args, &block) 
            self.to_h.send m, *args, &block
          end
          
          def to_h
            @parent.cache["assignments"]
          end
          
          def name_by_id(id)
            self.to_h.keys.each do |key|
              unless self.to_h[key].nil? or self.to_h[key].empty?
                self.to_h[key].each do |obj|
                  return obj['name'] if obj["id"].to_s == id.to_s
                end
              end
            end
            return nil
          end
          
          def type_by_id(id)
            self.to_h.keys.each do |key|
              unless self.to_h[key].nil? or self.to_h[key].empty?
                self.to_h[key].each do |obj|
                  return key if obj["id"].to_s == id.to_s
                end
              end
            end
            return nil
          end
        end
      end
    end
  end
end
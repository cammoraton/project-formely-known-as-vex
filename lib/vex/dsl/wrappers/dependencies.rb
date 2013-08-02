module Vex
  module Dsl
    module Wrappers
      module Dependencies
        def dependencies
          @dependencies ||= Vex::Dsl::Wrappers::Dependencies::Wrapper.new(self)
        end
      
        class Wrapper
          def initialize(object)
            @object = object
          end
          
          def triggered_by
            to_tree(@object.dependency_cache.find_by_keys(@object.vex_dependencies["triggered_by"], "triggered_by"))
          end
        
          def triggers
            to_tree(@object.dependency_cache.find_by_keys(@object.vex_dependencies["triggers"], "triggers"))
          end
          
          def flatten_to_ids(search = [], merge_space = :all)
            ids = flatten_for_ids(@object.dependency_cache.merged_cache(search, merge_space))
            return ids.select{ |a| a if a.to_s.length > 0 }.uniq
          end
          
          private
          def to_tree(array = [])
            { "name" => @object.name,
              "type" => @object._type,
              "id"   => @object._id,
              "children" => array }
          end
          
          def flatten_for_ids(children)
            ids = Array.new
            return ids if children.nil? or children.empty?
            children.each do |child|
              ids.push(child["id"]) unless ids.include?(child["id"])
              ids = ids + flatten_for_ids(child["children"])
            end
            return ids.select{ |a| a if a.to_s.length > 0 }.uniq
          end
        
        end
      end
    end
  end
end
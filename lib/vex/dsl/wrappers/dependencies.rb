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
            to_tree(@object.vex_associations.by_types(build_search_map("triggered_by"), true))
          end
        
          def triggers
            to_tree(@object.vex_associations.by_types(build_search_map("triggers"), true))
          end
          
          private
          def build_search_map(keyword)
            raise(ArgumentError, "Keyword must be passed") if keyword.nil?
            words = []
            @object.vex_dependencies[keyword].map{|a| a.to_s.singularize.camelize}.each do |word|
              words = ( words + [word] + self.class.const_get(word).vex_dependencies[keyword].map{|a| a.to_s.singularize.camelize }).uniq
            end
            puts words.inspect
            return words
          end
          
          def children_of_the_array(array, source)
            retval = array.select{ |a| a if a["source"] == source or a["source"].include?(source)}.map{ |a| { "name" => a["name"],
                                                                                                              "type" => a["type"],
                                                                                                              "id"   => a["id"],
                                                                                                              "children" => [] } }
            retval.each do |children|
              children["children"] = children_of_the_array(array, children["id"])
            end
            return retval
          end
          
          def to_tree(array = [])
            puts array.inspect
            puts ""
            
            { "name" => @object.name,
              "type" => @object._type,
              "id"   => @object._id,
              "children" => children_of_the_array(array, @object._id.to_s) }
          end
        end
      end
    end
  end
end
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
          
          def find_by_id(hash, id)
            hash.select{}
          end
          
          def to_tree(array = [])
            sourced_tree = Array.new
            working = array.dup
            query_depth = @object.vex_associations.query_depth
            working.each do |object|
              unless object["source"] != @object._id.to_s
                sourced_tree.push({ "name"     => object["name"],
                                    "type"     => object["type"],
                                    "id"       => object["id"],
                                    "children" => [] })
                working.delete(object)
              end
            end
            iterations = query_depth * 5  # Sanity/Safety check: Break out of loop after a certain number of iterations even if the queue isn't empty.
            unless query_depth < 1
              while !working.empty? and iterations > 0
                iterations = iterations - 1
                working.each do |object|
                  if object["source"].is_a? Array
                    find = sourced_tree.select{ |a| a if object["source"].include?(a["id"]) }
                    unless find.empty?
                      find.first["children"].push({ "name"     => object["name"],
                                                    "type"     => object["type"],
                                                    "id"       => object["id"],
                                                    "children" => [] })
                      object["source"].delete(find.first["id"])
                      working.delete("object") if object["source"].empty?
                    end
                  else
                    find = sourced_tree.select{ |a| a if a["id"] == object["source"] }
                    unless find.empty?
                      find.first["children"].push({ "name"     => object["name"],
                                                    "type"     => object["type"],
                                                    "id"       => object["id"],
                                                    "children" => [] })
                      working.delete(object)
                    end
                  end
                end
              end
            end
            
            { "name" => @object.name,
              "type" => @object._type,
              "id"   => @object._id,
              "children" => sourced_tree }
          end
        end
      end
    end
  end
end
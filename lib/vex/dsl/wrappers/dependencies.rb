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
            to_tree(@object.vex_associations.by_types(@object.vex_dependencies["triggered_by"].map{|a| a.to_s.singularize.camelize}, true))
          end
        
          def triggers
            to_tree(@object.vex_associations.by_types(@object.vex_dependencies["triggers"].map{|a| a.to_s.singularize.camelize}, true))
          end
          
          private
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
            unless query_depth < 1
              (1..query_depth).each do |iterate|
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
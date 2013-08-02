module Vex
  module Dsl
    module Wrappers
      module Cache
        class Dependencies
          def initialize(parent)
            @object = parent
          end
          
          # Pass things through to the underlying object
          def method_missing(m, *args, &block) 
            self.to_h.send m, *args, &block
          end
          
          # Access the underlying object
          def to_h
            @object.cache["dependencies"]
          end
          
          def find_by_id(id, search = [], merge_space = "triggers")
            search_array_by_id(id, merge_caches(search, merge_space))
          end
          
          def find_by_keys(search = [], merge_space = "triggers")
            merge_caches(search, merge_space)
          end
          
          def merged_cache(search = [], merge_space = "triggers")
            merge_caches(search, merge_space)
          end
          
          private
          def merge_caches(search = [], search_space = "triggers")
            puts search.inspect
            # Work on a duplicate of our assignment_cache so we don't corrupt it
            retval = assignment_cache(search).dup
            # Make damn sure the hashes are initialized
            self.to_h[search_space] = Hash.new if self.to_h[search_space].nil?
            self.to_h[search_space].keys.each do |key|
              unless search_array_by_id(key.to_s, retval).nil?
                search_array_by_id(key, retval)["children"] += self.to_h[search_space][key]
              end
            end
            return retval
          end
          
          def search_array_by_id(id, search = [])
            search.each do |val|
              test = search_by_id(id, val)
              return test unless test.nil?
            end
            return nil
          end
          
          def search_by_id(id, hash = {})
            return nil unless hash.is_a? Hash
            return nil if hash["children"].nil?
            return hash if hash["id"].to_s == id.to_s
            hash["children"].each do |child|
              test = search_by_id(id, child)
              return test unless test.nil?
            end
            return nil
          end
          
          def assignment_cache(search = [])
            retval = []
            #return retval if search.nil?
            search.each do |key|
              unless @object.assignment_cache[key.to_s].nil? or @object.assignment_cache[key.to_s].empty?
                @object.assignment_cache[key.to_s].each do |assignment|
                  id = assignment["id"].to_s
                  name = @object.assignment_cache.name_by_id(id)
                  type = @object.assignment_cache.type_by_id(id)
                  source = @object.assignment_sources_cache.source_by_id(id).to_s
                  source_name = @object.assignment_cache.name_by_id(source)
                  source_type = @object.assignment_cache.type_by_id(source)
                  push_value = { "id" => id, "name" => name, "type" => type.to_s.singularize.camelize, "children" => []}
                  unless source.nil?
                    unless source_name.nil? or source_type.nil?
                      if retval.select{|a| a if a["id"].to_s == source.to_s }.empty?
                        retval.push({ "id" => source, "name" => source_name, "type" => source_type.to_s.singularize.camelize, "children" => [] }) 
                      end
                      check = retval.select{|a| a if a["id"].to_s == source.to_s }.first
                      check["children"].push(push_value) if check["children"].select{|a| a if a["id"].to_s == id.to_s }.empty?
                    else
                      retval.push(push_value) if retval.select{|a| a if a["id"] == id }.empty?
                    end
                  end
                end
              end
            end
            return retval
          end
        end
      end
    end
  end
end

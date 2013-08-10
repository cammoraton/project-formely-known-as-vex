module Vex
  module Dsl
    module Wrappers
      module Parameters
        # For some reason having this here and mixed in makes it never called.
        # Maybe a namespace conflict?
        # def parameters
        #   params_to_array(self.data)
        # end
        
        # Enables the underlying array to be treated as an array of key/value hashes
        def parameters=(val)
          if val.is_a? Array
            self.data = array_to_params(val)
          elsif val.is_a? Hash
            self.data = val
          else
            raise(ArgumentError, "Value must be a hash or array")
          end
        end
        
        private
        def params_to_array(val)
          return nil unless val.is_a? Hash
          retval = Array.new
          val.each_pair do |key, value|
            if value.is_a? Hash
              retval.push({"key" => key, "parameters" => params_to_array(value) })
            elsif value.is_a? Array
              retval.push({"key" => key, "value" => value})
            else
              retval.push({"key" => key, "value" => value})
            end  
          end
          return retval
        end
        
        def array_to_params(val)
          return nil unless val.is_a? Array
          retval = Hash.new
          val.each do |value|
            unless value["key"].nil? or value["key"].length < 2
              if !value["parameters"].nil?
                retval[value["key"]] = array_to_params(value["parameters"])
              elsif value["value"].nil? and value["value"].length > 2
                retval[value["key"]] = value["value"]
              end
            end
          end
          return retval
        end
        
        class Wrapper
          def initialize(key,value)
            @key = key            
            @value = value
          end
          def key
            @key
          end
          def value
            @value
          end
        end
      end
    end
  end
end
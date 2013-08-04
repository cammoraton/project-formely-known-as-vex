module Vex
  module Dsl
    module Wrappers
      module Parameters
        def parameters
          logger.debug("[DEBUG] - Parameters called" )
          retval = Array.new
          self.data.each_pair do |key,value|
            
            logger.debug("[DEBUG] --- Wrapping #{key} = #{value}" )
            retval.push(Vex::Dsl::Wrappers::Parameters::Wrapper.new(key, value))
          end
          retval
        end
  
        def parameters=(val)
          logger.debug("[DEBUG] - Parameters passed as #{val.inspect}" )
          if val.is_a? Array
            logger.debug("[DEBUG] --- Parsing array" )
            new_hash = Hash.new
            val.each do |value|
              new_hash[value["key"]] = value["value"]
            end
            logger.debug("[DEBUG] --- Setting data to #{new_hash.inspect}" )
            self.data = new_hash
          elsif val.is_a? Hash
            self.data = val
          else
            raise(ArgumentError, "Value must be a hash or array")
          end
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
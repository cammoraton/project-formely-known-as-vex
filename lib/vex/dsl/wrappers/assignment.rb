module Vex
  module Dsl
    module Wrappers
      module Assignment
        class Wrapper
          def initialize(object, klass)
            @object = object
            @klass  = klass
            @associations = @object.vex_associations.by_type(klass.to_s)
          end
          
          # We're really an array.  We swear!
          def method_missing(m, *args, &block)
            self.to_a.send m, *args, &block
          end
          
          # Refresh from associations
          def refresh
            @associations = @object.vex_associations.by_type(klass.to_s).dup
          end
          
          def to_a
            @associations #||= @object.vex_associations.by_type(klass.to_s) # This caused stack level too deep errors chaining off method_missing.
                                                                            # Initialize it in the initializer and all is golden.  Something about ruby I
                                                                            # don't understand is going on here.
          end
          
         
          def ids
            self.to_a.map{ |a| a["id"] }
          end
          
          def names
            self.to_a.map{ |a| a["name"] }
          end
          
          def local
            self.to_a.select{|a| a if a["source"].to_s == @object._id.to_s }
          end
          
          def local_ids
            self.local.map{ |a| a["id"] }
          end
           
          def source(id)
            inherited_object = self.to_a.select{|a| a if a["id"] == id }   # Find the damn thing!
            return nil if inherited_object.nil? or inherited_object.empty? # This should never happen unless we get a bad id
            inherited_object = inherited_object.first                      # There should only be one, but....
            source = @object.vex_associations.to_a.select{|a| a if a["id"] == inherited_object["source"]}
            return nil if source.nil? or source.empty?                     # This should never happen
            return source.map{ |a| { :type => a["type"], :name => a["name"], :id => a["id"]}}
          end
          
          def ids=(val)
            raise(ArgumentError, "Token ids must be passed as an array") unless val.is_a? Array
            current_ids = self.local.map{ |a| a["id"].to_s}
            (val - current_ids).each do |add|
              @object.assignment_ids << BSON::ObjectId(add)
            end
            (current_ids - val).each do |del|
              @object.assignment_ids.delete(BSON::ObjectId(del))
            end
            # TODO: update cache? Do we ever do this without saving?
          end
          
          # Shovel assignment
          def <<(val)
            raise(ArgumentError, "Can only add values of type #{@klass.to_s}") unless val.is_a? @klass
            @object.assignment_ids.push(val._id) unless @object.assignment_ids.include?(val._id)
            # TODO: push to cache?  Do we ever do this without saving?
          end
        end
      end
    end
  end
end
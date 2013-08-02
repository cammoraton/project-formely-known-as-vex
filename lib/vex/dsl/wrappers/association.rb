module Vex
  module Dsl
    module Wrappers
      module Association
        class Wrapper
          def initialize(object, klass, options)
            @parent = object
            @klass = klass
            @options = options
          end
          
          # We're really an array, we swear
          def method_missing(m, *args, &block) 
            self.to_a.send m, *args, &block
          end
             
          def reload
            @local_only = @klass.where( :_id => { :$in => @parent.assignment_ids } ).all
            @assignments = query
          end
          
          def to_a
            @assignments ||= query
          end
    
          def local
            @local_only ||= @klass.where( :_id => { :$in => @parent.assignment_ids } ).all
          end
    
          def find_by_id(id)
            self.to_a.each do |assign|
              return assign if assign._id.to_s == id.to_s
            end
            return nil
          end
    
          # For tokeninput assignment
          def ids=(val)
            raise(ArgumentError, "ids must be passed as an array") unless val.is_a? Array
            current_ids = self.local.map{ |a| a._id.to_s}
            (val - current_ids).each do |add|
              @parent.assignment_ids << BSON::ObjectId(add)
            end
            (current_ids - val).each do |del|
              @parent.assignment_ids.delete(BSON::ObjectId(del))
            end
          end
    
          # Shovel assignment
          def <<(val)
            raise(ArgumentError, "Can only add values of type #{@klass.to_s}") unless val.is_a? @klass
            @object.assignment_ids.push(val._id) unless @object.assignment_ids.include?(val._id)
            self.to_a.push(val) unless self.to_a.include?(val)
          end
          
          private
          def query
            results = self.local
            unless @options[:through].nil?
              if @options[:through].is_a? Array
                @options[:through].each do |inherit|
                  eval = @parent.send(inherit).to_a
                  unless eval.empty?
                    eval.each do |item|
                      results += item.send(@klass.to_s.downcase.pluralize).to_a
                    end
                  end
                end
              else
                eval = @parent.send(@options[:through]).to_a
                unless eval.empty?
                  eval.each do |item|
                    results += item.send(@klass.to_s.downcase.pluralize).to_a
                  end
                end
              end
            end
            results.uniq ||= []
          end
        end
      end
    end
  end
end
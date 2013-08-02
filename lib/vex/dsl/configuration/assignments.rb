module Vex
  module Dsl
    module Configuration
      module Assignments
        extend ActiveSupport::Concern
      
        module ClassMethods
          
          # The main distinction between these are if we trigger a dependency or if we are triggered
          def assigned(association_id, options = {})
            vex_dependencies["triggered_by"].push(association_id) unless vex_dependencies["triggered_by"].include?(association_id)
            actual_assignment(association_id, options)
          end
        
          # We trigger one
          def assigned_to(association_id, options = {})
            vex_dependencies["triggers"].push(association_id) unless vex_dependencies["triggers"].include?(association_id)
            actual_assignment(association_id, options)
          end
        
          # And some are both
          def assigned_and_assigned_to(association_id, options = {})
            vex_dependencies["triggers"].push(association_id) unless vex_dependencies["triggers"].include?(association_id)
            vex_dependencies["triggered_by"].push(association_id) unless vex_dependencies["triggered_by"].include?(association_id)
            actual_assignment(association_id, options)
          end
        
          def vex_assignments
            @vex_assignments ||= {}
          end
          
          def vex_dependencies
            @vex_dependencies ||= { "triggers" => [], "triggered_by" => []}
          end
          
          private
          def actual_assignment(association_id, options = {})
            self.vex_assignments[association_id] = options
            
            attr_accessible "#{association_id.to_s.singularize}_tokens".to_sym
            attr_accessible "#{association_id.to_s}".to_sym
            attr_reader     "#{association_id.to_s}".to_sym
            attr_reader     "#{association_id.to_s.singularize}_tokens".to_sym
            
            module_eval <<-end_eval
              def #{association_id.to_s.singularize}_tokens=(ids)
                self.#{association_id.to_s}.ids = ids.split(',')
              end
            
              def #{association_id.to_s}
                @#{association_id.to_s} ||= Vex::Dsl::Wrappers::Association::Wrapper.new(self, #{association_id.to_s.singularize.camelize}, #{options.inspect})
              end
            end_eval
          end
        end
      
        def self.included(base)
          base.extend ClassMethods 
        end
        
        def vex_assignments
          self.class.vex_assignments
        end
        
        def vex_dependencies
          self.class.vex_dependencies
        end
        
        def associated_via(object)
          if object.assignment_ids.include?(self._id) or self.assignment_ids.include?(object._id)
            return object
          end
          eval = object.vex_assignments[self.class.to_s.downcase.pluralize.to_sym]
          return nil if eval.nil?
          unless eval[:through].nil?
            if eval[:through].is_a? Array
              eval[:through].each do |item|
               unless item.is_a? Hash
                 source = self.send(item).to_a.select{ |a| a.assignment_ids.include?(object._id)}
                 return source.first unless source.empty?
               else
                 source = self.send(item.keys.first).to_a.select{ |a| a.assignment_ids.include?(object._id)}
                 return source.first unless source.empty?
               end
              end
            else
              unless !self.respond_to?(eval[:through])
                source = self.send(eval[:through]).to_a.select{ |a| a.assignment_ids.include?(object._id)}
                return source.first unless source.empty?
              end
            end
          end
          return nil
        end
      end
    end
  end
end
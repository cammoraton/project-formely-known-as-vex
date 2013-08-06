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
                @#{association_id.to_s} ||= Vex::Dsl::Wrappers::Assignment::Wrapper.new(self, #{association_id.to_s.singularize.camelize})
              end
            end_eval
          end
        end
      
        def self.included(base)
          base.extend ClassMethods 
        end
        
        def vex_associations
          @vex_associations ||= Vex::Dsl::Wrappers::Association::Wrapper.new(self)
        end
        
        def vex_assignments
          self.class.vex_assignments
        end
        
        def vex_dependencies
          self.class.vex_dependencies
        end
      end
    end
  end
end
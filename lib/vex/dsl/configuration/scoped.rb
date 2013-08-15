module Vex
  module Dsl
    module Configuration
      module Scoped
        extend ActiveSupport::Concern
      
        module ClassMethods
          def vex_scoped
            @vex_scoped ||= false
          end
          
          def vex_scopes
            @vex_scopes ||= []
          end
          
          def has_scopes
            @vex_scoped = true
            #many :scopes
          end
          
          def scoped_on(values)
            @vex_scopes = values
          end
        end
        
        def self.included(base)
          base.extend ClassMethods
        end
        
        def has_scopes?
          self.class.vex_scoped
        end
        
        def vex_scopes
          self.class.vex_scopes
        end
      end
    end
  end
end
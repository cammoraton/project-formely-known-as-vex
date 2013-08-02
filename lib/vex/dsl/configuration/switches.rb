module Vex
  module Dsl
    module Configuration
      module Switches
        extend ActiveSupport::Concern
        
        module ClassMethods
          def fact_source
            @fact_source ||= false
          end
          
          def hiera_view
            @hiera_view ||= false
          end
          
          def has_facts
            @fact_source = true
          end
          
          def simulates_hiera
            @hiera_view = true
          end
        end
        
        def self.included(base)
          base.extend(ClassMethods)
        end
        
        def has_facts?
          self.class.fact_source
        end
        
        def simulates_hiera?
          self.class.hiera_view
        end
      end
    end
  end
end
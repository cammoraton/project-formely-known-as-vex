module Vex
  module Dsl
    module Configuration
      module Routing
        extend ActiveSupport::Concern
        
        module ClassMethods
          def routing_path
            @vex_route ||= self.to_s.pluralize.downcase
          end
          
          def routed_as(value)
            @vex_route = value
          end
        end
        
        def self.included(base)
          base.extend(ClassMethods)
        end
        
        def routing_path
          self.class.routing_path
        end
      end
    end
  end
end
 
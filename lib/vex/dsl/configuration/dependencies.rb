module Vex
  module Dsl
    module Configuration
      module Dependencies
        extend ActiveSupport::Concern
      
        module ClassMethods
          def deduplicates_on(val, options = {})
            
          end
        end
        
        def self.included(base)
          base.extend ClassMethods
        end
      end
    end
  end
end
module Vex
  module Dsl
    module Configuration
      module Display
        extend ActiveSupport::Concern
        
        module ClassMethods
          
        end
        
        def self.included(base)
          base.extend ClassMethods
        end
      end
    end
  end
end

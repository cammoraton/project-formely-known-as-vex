module Vex
  module Dsl
    module Configuration
      module Display
        extend ActiveSupport::Concern
        
        module ClassMethods
          def vex_layout
            @vex_layout ||= "grid"
          end
          
          def vex_layout_order
            @vex_layout_order ||= "alphabetical"
          end
          
          def layout(layout, order = "alphabetical")
            @vex_layout = layout
            @vex_layout_order = order
          end
        end
        
        def self.included(base)
          base.extend ClassMethods
        end
        
        def vex_layout
          self.class.vex_layout
        end
        
        def vex_layout_order
          self.class.vex_layout_order
        end
      end
    end
  end
end

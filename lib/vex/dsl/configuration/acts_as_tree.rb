module Vex
  module Dsl
    module Configuration
      module ActsAsTree
        extend ActiveSupport::Concern
        
        module ClassMethods
          def acts_as_tree
            many       :children, :as => :parent
            belongs_to :parent,   :polymorphic => true
          end
        end
        
        def self.included(base)
          base.extend(ClassMethods)
        end
      end
    end
  end
end
 

# Really just a switch and an extra association.  The bulk of this is in other libraries.
module Vex
  module Dsl
    module Configuration
      module ActsAsTree
        extend ActiveSupport::Concern
      
        module ClassMethods
          def is_tree
            @vex_acts_as_tree ||= false
          end
          
          def acts_as_tree
            @vex_acts_as_tree = true
            
            belongs_to :parent, :polymorphic => true
            many :children, :as => :parent, :class => self
            
            before_prep :inherit_data_from_parents
          end
        end
        
        def self.included(base)
          base.extend ClassMethods
        end
        
        def is_tree?
          self.class.is_tree
        end
        
        def inherit_data_from_parents
          return {} if self.parent.nil?
          self.parent.prep_hash
        end
      end
    end
  end
end
Dir[File.dirname(__FILE__) + '/wrappers/*.rb'].each {|file| require file }

module Vex
  module Dsl
    module Wrappers
      extend ActiveSupport::Concern
      
      include Vex::Dsl::Wrappers::Association
      include Vex::Dsl::Wrappers::Dependencies
      module ClassMethods
        
      end
      def self.included(base)
        base.extend ClassMethods
      end
    end
  end
end
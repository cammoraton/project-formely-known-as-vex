Dir[File.dirname(__FILE__) + '/configuration/*.rb'].each {|file| require file }

module Vex
  module Dsl
    module Configuration
      extend ActiveSupport::Concern
      
      include Vex::Dsl::Configuration::ActsAsTree
      include Vex::Dsl::Configuration::Assignments
      include Vex::Dsl::Configuration::Cache
      include Vex::Dsl::Configuration::Dependencies
      include Vex::Dsl::Configuration::Routing
      include Vex::Dsl::Configuration::Scoped
      include Vex::Dsl::Configuration::Switches
      module ClassMethods
        include Vex::Dsl::Configuration::ActsAsTree::ClassMethods
        include Vex::Dsl::Configuration::Assignments::ClassMethods
        include Vex::Dsl::Configuration::Cache::ClassMethods
        include Vex::Dsl::Configuration::Dependencies::ClassMethods
        include Vex::Dsl::Configuration::Routing::ClassMethods
        include Vex::Dsl::Configuration::Scoped::ClassMethods
        include Vex::Dsl::Configuration::Switches::ClassMethods
      end
      
      def self.included(base)
        base.extend ClassMethods
      end
    end
  end
end
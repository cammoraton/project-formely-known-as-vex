module Vex
  module Parser
    class Model < Vex::Parser::Common
      def initialize(model_name, lines)
        @name = model_name.downcase.singularize
        @config = Hash.new
        
        line_parser(lines)
      end
      
      def name
        @name
      end
      
      def config
        @config
      end
      
      def assigned_to(args)
        @config["assigned_to"] = args
      end
      
      def assigned(args)
        @config["assigned"] = args
      end
      
      def assigned_and_assigned_to(args)
        @config["assigned_and_assigned_to"] = args
      end
      
      
      def puppet_type(arg)
        case arg
        when "node"
          @config["has_facts"] = true
          @config["simulates_hiera"] = true
        when "class"
          
        end
      end
      
      def routed_as(arg)
        @config["routed_as"] = arg
      end
      
      def scopes(args)
        @config["scopes"] = args
      end
      
      def self_joining(arg)
        case arg.downcase
        when "enabled"
          @config["acts_as_tree"] = true
        when "true"
          @config["acts_as_tree"] = true
        end
      end
      
    end
  end
end
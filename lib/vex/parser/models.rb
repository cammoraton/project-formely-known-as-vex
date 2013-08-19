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
      
      
      def puppet_type(args)
        puts "#{@name} corresponds to puppet type #{args.inspect}"
      end
      
      def routed_as(args)
        puts "#{@name} will be routed as #{args.inspect}"
      end
      
      def scopes(args)
        puts "#{@name} is scoped on #{args.inspect}"
      end
      
      def self_joining(args)
        puts "#{@name} self_joining value is #{args.inspect}"
      end
      
    end
  end
end
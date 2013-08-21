module Vex
  module Parser
    class Main < Vex::Parser::Common
      def initialize(lines)
        line_parser(lines)
      end
      
      def base_object(arg)
        Vex::Application.config.dashboard_base_object = arg
      end
      
      def database(args)
        puts "Database: #{args.inspect}"
      end
      
      def cache(arg)
        case arg.downcase
        when "false"
          Vex::Application.config.cache_associations = false
        when "disabled"
          Vex::Application.config.cache_associations = false
        else
          Vex::Application.config.cache_associations = true
        end
      end
    end
  end
end
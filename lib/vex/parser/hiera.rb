require "#{File.dirname(__FILE__)}/common.rb"

module Vex
  module Parser
    class Hierarchy < Vex::Parser::Common
      def initialize(lines)
        line_parser(lines)
      end
      
    end
  end
end
module Vex
  module Parser
    class Main < Vex::Parser::Common
      def initialize(lines)
        puts "Main called"
        puts lines.inspect
      end
    end
  end
end
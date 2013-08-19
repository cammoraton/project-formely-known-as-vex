module Vex
  module Parser
    class Model < Vex::Parser::Common
      def initialize(model_name, lines)
        puts "Model called"
        puts lines.inspect
      end
    end
  end
end
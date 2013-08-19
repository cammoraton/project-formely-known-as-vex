module Vex
  module Parser
    class Common
      private
      def action(act, arg)
        if arg.is_a? String and arg.match(/,/)
          arg.split(',')
          self.send(act, arg.map{|a| a.chomp.strip }) rescue nil # Don't whine
        else
          self.send(act, arg) rescue nil  # Don't whine
        end
      end
      
      def line_parser(lines)
        lines_block = Array.new
        delegated = nil
        lines.each do |line|
          if line.match(/=/)
            delegate(delegated, lines_block) if delegated
            
            delegated = nil
            lines_block = Array.new
            
            parse = line.split('=')
            action(parse.first.chomp.strip.downcase, parse.last.chomp.strip)
          elsif line.match(/[:-]/)
            unless line.match(/^-/)
              delegate(delegated, lines_block) if delegated
              delegated = line.gsub(/[:]/, '').strip.chomp
            else
              lines_block.push(line.gsub(/[-]/, '').strip.chomp)
            end
          end
        end
        
        delegate(delegated, lines_block) if delegated
      end
      
      def delegate(action, lines)
        args = Array.new
        lines.each do |line|
          if line.match(/[:]/)
            array = line.split(':')
            key = array.first.chomp.strip
            array.delete(array.first)
            
            hash = { key => array.map{ |a| a.chomp.strip }}
            args.push(hash)
          else
            args.push(line.chomp.strip)
          end
        end
        action(action, args)
      end
    end
  end
end
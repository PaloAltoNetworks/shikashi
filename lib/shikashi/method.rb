module Shikashi
  class Method
    class Node
      attr_reader :file
      attr_reader :line

      def initialize(file_,line_)
        @file = file_
        @line = line_
      end
    end

    begin
      instance_method('body')
    rescue
      def body
        if source_location
          Method::Node.new(source_location[0], source_location[1])
        else
          Method::Node.new('',0)
        end
      end
    end
  end
end
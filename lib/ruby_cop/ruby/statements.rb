module RubyCop
  module Ruby
    class Statements < List
      # def inspect
      #   @elements.collect { |e| e.inspect }.join
      # end

      def to_block(params)
        Block.new(@elements, params)
      end

      def to_chained_block(blocks=nil, params=nil)
        ChainedBlock.new(blocks, @elements, params)
      end

      def to_program(src, filename)
        Program.new(src, filename, @elements)
      end
    end

    class Program < Statements
      def initialize(src, filename, statements)
        @src = src
        @filename = filename
        super(statements)
      end

      attr_reader :src
      attr_reader :filename
    end
  end
end
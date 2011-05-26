module RubyCop
  module Ruby
    class Case < Node
      def initialize(expression, block)
        @expression = expression
        @block = block
      end

      attr_reader :expression
      attr_reader :block
    end

    class When < ChainedBlock
      def initialize(expression, statements, block=nil)
        @expression = expression
        super([block], statements)
      end

      attr_reader :expression
    end
  end
end
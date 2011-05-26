module RubyCop
  module Ruby
    class Block < Statements
      def initialize(statements, params=nil)
        @params = params
        super(statements)
      end

      attr_reader :params
    end

    class ChainedBlock < Block
      def initialize(blocks, statements, params=nil)
        @blocks = Array(blocks).compact
        super(statements, params)
      end

      attr_reader :blocks
    end
  end
end
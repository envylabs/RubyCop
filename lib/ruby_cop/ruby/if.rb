module RubyCop
  module Ruby
    class If < ChainedBlock
      def initialize(expression, statements=nil, else_block=nil)
        @expression = expression
        super([else_block], statements, nil)
      end
      attr_reader :expression
    end

    class Unless < If
    end

    class Else < Block
    end

    class IfMod < Block
      def initialize(expression, statements)
        @expression = expression
        super(statements)
      end
      attr_reader :expression
    end

    class UnlessMod < IfMod
    end

    class RescueMod < IfMod
    end
  end
end
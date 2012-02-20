module Rubycop
  module Analyzer
    module Ruby
      class While < Block
        def initialize(expression, statements)
          @expression = expression
          super(statements)
        end

        attr_reader :expression
      end

      class WhileMod < Block
        def initialize(expression, statements)
          @expression = expression
          super(statements)
        end

        attr_reader :expression
      end

      class Until < While
      end

      class UntilMod < WhileMod
      end
    end
  end
end
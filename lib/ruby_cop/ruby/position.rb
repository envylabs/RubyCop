module RubyCop
  module Ruby
    class Position
      def initialize(lineno, column)
        @lineno = lineno
        @column = column
      end

      attr_reader :lineno
      attr_reader :column
    end
  end
end
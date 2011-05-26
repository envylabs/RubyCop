module RubyCop
  module Ruby
    class For < Block
      def initialize(variable, range, statements)
        @variable = variable
        @range = range
        @statements = statements
      end

      attr_reader :variable
      attr_reader :range
      attr_reader :statements
    end
  end
end
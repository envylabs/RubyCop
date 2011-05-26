module RubyCop
  module Ruby
    class Range < Node
      def initialize(min, max, exclude_end)
        @min = min
        @max = max
        @exclude_end = exclude_end
      end

      attr_reader :min
      attr_reader :max
      attr_reader :exclude_end
    end
  end
end
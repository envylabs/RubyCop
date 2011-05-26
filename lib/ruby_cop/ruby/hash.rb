module RubyCop
  module Ruby
    class Hash < Node
      def initialize(assocs)
        @assocs = assocs
      end

      attr_reader :assocs
    end
  end
end
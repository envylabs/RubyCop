module RubyCop
  module Ruby
    class Node
      def accept(visitor)
        visitor.visit(self)
      end
    end
  end
end
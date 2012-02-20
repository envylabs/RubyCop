module Rubycop
  module Analyzer
    module Ruby
      class Node
        def accept(visitor)
          visitor.visit(self)
        end
      end
    end
  end
end
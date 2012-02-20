module Rubycop
  module Analyzer
    module Ruby
      class List < Node
        def initialize(elements=nil)
          @elements = Array(elements).compact # TODO: compact might cause problems here
        end

        attr_reader :elements

        def add(element)
          @elements.push(element)
        end
      end
    end
  end
end
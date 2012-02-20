module Rubycop
  module Analyzer
    module Ruby
      class Args < List
        attr_reader :block

        def add_block(block)
          @block = block
        end

        def to_array
          Array.new(@elements)
        end
      end

      class Arg < Node
        def initialize(arg)
          @arg = arg
        end

        attr_reader :arg
      end

      class SplatArg < Arg
      end
    end
  end
end
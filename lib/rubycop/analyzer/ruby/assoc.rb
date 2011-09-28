module Rubycop
  module Analyzer
    module Ruby
      class Assoc < Node
        def initialize(key, value)
          @key = key
          @value = value
        end

        attr_reader :key
        attr_reader :value
      end
    end
  end
end
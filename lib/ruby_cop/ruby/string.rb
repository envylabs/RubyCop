module RubyCop
  module Ruby
    class StringConcat < List
    end

    class String < List
      # def inspect
      #   @elements.join.inspect
      # end
    end

    class DynaSymbol < String
    end

    class ExecutableString < String
      def to_dyna_symbol
        DynaSymbol.new(@elements)
      end
    end

    class Regexp < String
    end
  end
end
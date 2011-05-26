module RubyCop
  module Ruby
    class Token < Node
      def initialize(token, position)
        @token    = token
        @position = position
      end

      attr_reader :token
      attr_reader :position

      # def inspect
      #   "#{@token}<t>"
      # end
    end

    class Integer < Token
    end

    class Float < Token
    end

    class Char < Token
    end

    class Label < Token
    end

    class Symbol < Token
      # def inspect
      #   ":#{@token.inspect}"
      # end
    end

    class Keyword < Token
    end

    class Identifier < Token
      def assignment(rvalue, operator)
        LocalVariableAssignment.new(self, rvalue, operator)
      end
    end
  end
end
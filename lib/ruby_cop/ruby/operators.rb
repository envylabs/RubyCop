module RubyCop
  module Ruby
    class Operator < Node
    end

    class Unary < Operator
      def initialize(operator, operand)
        @operator = operator
        @operand  = operand
      end

      attr_reader :operator
      attr_reader :operand

      # def inspect
      #   "#{@operator}(#{@operand.inspect})"
      # end
    end

    class Binary < Operator
      def initialize(lvalue, rvalue, operator)
        @lvalue   = lvalue
        @rvalue   = rvalue
        @operator = operator
      end

      attr_reader :lvalue
      attr_reader :rvalue
      attr_reader :operator

      # def inspect
      #   "#{@lvalue.inspect} #{@operator} #{@rvalue.inspect}"
      # end
    end

    class IfOp < Operator
      def initialize(condition, then_part, else_part)
        @condition = condition
        @then_part = then_part
        @else_part = else_part
      end

      attr_reader :condition
      attr_reader :then_part
      attr_reader :else_part

      # def inspect
      #   "#{@condition.inspect} ? #{@then_part.inspect} : #{@else_part.inspect}"
      # end
    end
  end
end
module RubyCop
  module Ruby
    class Variable < Identifier
    end

    class ClassVariable < Variable
      def assignment(rvalue, operator)
        ClassVariableAssignment.new(self, rvalue, operator)
      end
    end

    class GlobalVariable < Variable
      def assignment(rvalue, operator)
        GlobalVariableAssignment.new(self, rvalue, operator)
      end
    end

    class InstanceVariable < Variable
      def assignment(rvalue, operator)
        InstanceVariableAssignment.new(self, rvalue, operator)
      end
    end
  end
end
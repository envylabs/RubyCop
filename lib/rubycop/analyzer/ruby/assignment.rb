module Rubycop
  module Analyzer
    module Ruby
      class Assignment < Node
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

      class ClassVariableAssignment < Assignment
      end

      class ConstantAssignment < Assignment
      end

      class GlobalVariableAssignment < Assignment
      end

      class InstanceVariableAssignment < Assignment
      end

      class LocalVariableAssignment < Assignment
      end

      class MultiAssignment < Assignment
      end

      class MultiAssignmentList < List
        def assignment(rvalue, operator)
          MultiAssignment.new(self, rvalue, operator)
        end
      end
    end
  end
end
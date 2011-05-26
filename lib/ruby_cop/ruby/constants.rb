module RubyCop
  module Ruby
    class Constant < Identifier
      attr_accessor :namespace

      def assignment(rvalue, operator)
        ConstantAssignment.new(self, rvalue, operator)
      end

      # def inspect
      #   @namespace ? "#{@namespace.inspect}::#{@token}" : @token
      # end
    end

    class Module < Node
      def initialize(const, body)
        @const = const
        @body  = body
      end

      attr_reader :const
      attr_reader :body
    end

    class Class < Node
      def initialize(const, superclass, body)
        @const = const
        @superclass = superclass
        @body = body
      end

      attr_reader :const
      attr_reader :superclass
      attr_reader :body
    end

    class SingletonClass < Node
      def initialize(superclass, body)
        @superclass = superclass
        @body = body
      end

      attr_reader :superclass
      attr_reader :body
    end
  end
end
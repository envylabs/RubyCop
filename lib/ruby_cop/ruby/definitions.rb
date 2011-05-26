module RubyCop
  module Ruby
    class Method < Node
      def initialize(target, identifier, params, body)
        @target     = target
        @identifier = identifier
        @params     = params
        @body       = body
      end

      attr_reader :target
      attr_reader :identifier
      attr_reader :params
      attr_reader :body
    end

    class Defined < Node
      def initialize(expression)
        @expression = expression
      end

      attr_reader :expression
    end
  end
end
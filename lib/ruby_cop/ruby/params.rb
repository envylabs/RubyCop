module RubyCop
  module Ruby
    class Params < List
      def initialize(params, optionals, rest, block)
        super((Array(params) + Array(optionals) << rest << block).flatten.compact)
      end
    end

    class RescueParams < List
      def initialize(types, var)
        if types
          errors = Ruby::Array.new(types)
          errors = Ruby::Assoc.new(errors, var) if var
          super(errors)
        else
          super()
        end
      end
    end
  end
end
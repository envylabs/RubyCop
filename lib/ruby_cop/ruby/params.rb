module RubyCop
  module Ruby
    class Params < List
      def initialize(*args)
        case args.size
        when 4 # Ruby 1.9
          params, optionals, rest, block = args
        when 6 # Ruby 2.0+
          params, optionals, rest, keywords, keywords_rest, block = args
        else raise "cannot handle #{args.size} parameter types: #{args.inspect}"
        end
        things = Array(params) + Array(optionals)
        things << rest << keywords << keywords_rest << block
        super(things.flatten.compact)
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

module Rubycop
  module Analyzer
    module Ruby
      class Call < Node
        def initialize(target, identifier, arguments=nil, block=nil)
          @target     = target
          @identifier = identifier
          @arguments  = arguments
          @block      = block
        end

        attr_reader :target
        attr_reader :identifier
        attr_accessor :arguments
        attr_accessor :block

        def assignment(rvalue, operator)
          self.class.new(@target, Identifier.new("#{@identifier.token}=", @identifier.position), @arguments, @block)
        end
      end

      class Alias < Node
        def initialize(new_name, old_name)
          @new_name = new_name
          @old_name = old_name
        end

        attr_reader :new_name
        attr_reader :old_name
      end
    end
  end
end
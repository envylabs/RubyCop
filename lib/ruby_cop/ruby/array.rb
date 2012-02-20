module RubyCop
  module Ruby
    class Array < List
      # def inspect
      #   '[%s]' % @elements.collect { |e| e.inspect }.join(', ')
      # end

      def to_array
        self
      end
    end
  end
end

module SlimLint
  module Filters
    # In Slim you don't need the do keyword sometimes. This
    # filter adds the missing keyword.
    #
    #   - 10.times
    #     | Hello
    #
    # @api private
    class DoInserter < Filter
      BLOCK_REGEX = /(\A(if|unless|else|elsif|when|begin|rescue|ensure|case)\b)|\bdo\s*(\|[^\|]*\|\s*)?\Z/

      # Handle control expression `[:slim, :control, code, content]`
      #
      # @param [String] code Ruby code
      # @param [Array] content Temple expression
      # @return [Array] Compiled temple expression
      def on_slim_control(code, content)
        code.value = code.value + ' do' unless code.value =~ BLOCK_REGEX || empty_exp?(content)
        @self[3] = compile(content)
        @self
      end

      # Handle output expression `[:slim, :output, escape, code, content]`
      #
      # @param [Boolean] escape Escape html
      # @param [String] code Ruby code
      # @param [Array] content Temple expression
      # @return [Array] Compiled temple expression
      def on_slim_output(escape, code, content)
        code.value = code.value + ' do' unless code.value =~ BLOCK_REGEX || empty_exp?(content)
        @self[4] = compile(content)
        @self
      end
    end
  end
end

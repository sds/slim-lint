module SlimLint
  module Filters
    # This filter annotates the sexp with indentation guidance, so that we can
    # generate Ruby code with reasonable indentation semantics.
    class AutoIndenter < Filter
      BLOCK_REGEX = /(\A(if|unless|else|elsif|when|begin|rescue|ensure|case)\b)|\bdo\s*(\|[^|]*\|\s*)?\Z/

      # Handle control expression `[:slim, :control, code, content]`
      #
      # @param [String] code Ruby code
      # @param [Array] content Temple expression
      # @return [Array] Compiled temple expression
      def on_slim_control(code, content)
        @self[3] = compile(content)
        if code.last.last.value =~ BLOCK_REGEX && content[0].value == :multi
          @self[3].insert(1, Sexp.new(:slim_lint, :indent, start: content.start, finish: content.start))
          @self[3].insert(-1, Sexp.new(:slim_lint, :outdent, start: content.finish, finish: content.finish))
        end

        @self
      end

      # Handle output expression `[:slim, :control, escape, code, content]`
      #
      # @param [String] code Ruby code
      # @param [Array] content Temple expression
      # @return [Array] Compiled temple expression
      def on_slim_output(escape, code, content)
        @self[4] = compile(content)
        if code.last.last.value =~ BLOCK_REGEX && content[0].value == :multi
          @self[4].insert(1, Sexp.new(:slim_lint, :indent, start: content.start, finish: content.start))
          @self[4].insert(-1, Sexp.new(:slim_lint, :outdent, start: content.finish, finish: content.finish))
        end

        @self
      end
    end
  end
end

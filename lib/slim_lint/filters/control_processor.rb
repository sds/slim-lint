# frozen_string_literal: true

module SlimLint
  module Filters
    # A dumbed-down version of {Slim::Controls} which doesn't introduce temporary
    # variables and other cruft (which in the context of extracting Ruby code,
    # results in a lot of weird cops reported by RuboCop).
    class ControlProcessor < Filter
      BLOCK_RE = /\A(if|unless)\b|\bdo\s*(\|[^|]*\|)?\s*$/

      # Handle output expression `[:slim, :output, escape, code, content]`
      #
      # @param _escape [Boolean]
      # @param code [Sexp]
      # @param content [Sexp]
      # @return [Sexp]
      def on_slim_output(_escape, code, content)
        _, lines = code

        code.start = @self.start
        code.finish = @self.finish
        code << compile(content)

        if lines.last[BLOCK_RE]
          code << Sexp.new(Atom.new(:code, pos: code.finish), "end", start: code.finish, finish: code.finish)
        end

        Sexp.new(
          Atom.new(:dynamic, pos: code.start),
          code,
          start: code.start,
          finish: code.finish
        )
      end

      # Handle text expression `[:slim, :text, type, content]`
      #
      # @param _type [Symbol]
      # @param content [Sexp]
      # @return [Sexp]
      def on_slim_text(_type, content)
        compile(content)
      end
    end
  end
end

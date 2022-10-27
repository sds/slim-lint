# frozen_string_literal: true

module SlimLint
  module Filters
    # A dumbed-down version of {Slim::Controls} which doesn't introduce temporary
    # variables and other cruft (which in the context of extracting Ruby code,
    # results in a lot of weird cops reported by RuboCop).
    class ControlProcessor < Filter
      BLOCK_RE = /\A(if|unless)\b|\bdo\s*(\|[^|]*\|)?\s*$/

      # Handle control expression `[:slim, :control, code, content]`
      #
      # @param code [String]
      # @param content [Sexp]
      # @return [Sexp]
      def on_slim_control(code, content)
        Sexp.new(
          Atom.new(:multi, pos: @self.start),
          Sexp.new(Atom.new(:code, pos: code.start), code, start: code.start, finish: code.finish),
          compile(content),
          start: @self.start,
          finish: @self.finish
        )
      end

      # Handle output expression `[:slim, :output, escape, code, content]`
      #
      # @param _escape [Boolean]
      # @param code [String]
      # @param content [Sexp]
      # @return [Sexp]
      def on_slim_output(_escape, code, content)
        compiled = compile(content)

        if code[BLOCK_RE]
          Sexp.new(
            Atom.new(:multi, pos: @self.start),
            Sexp.new(Atom.new(:code, pos: code.start), code, compiled, start: code.start, finish: compiled.finish),
            Sexp.new(Atom.new(:code, pos: code.finish), "end", start: code.finish, finish: compiled.finish),
            start: @self.start,
            finish: @self.finish
          )
        else
          Sexp.new(
            Atom.new(:multi, pos: @self.start),
            Sexp.new(Atom.new(:dynamic, pos: code.start), code, start: code.start, finish: code.finish),
            compiled,
            start: @self.start,
            finish: @self.finish
          )
        end
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

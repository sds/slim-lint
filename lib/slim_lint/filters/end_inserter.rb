module SlimLint
  module Filters
    # In Slim you don't need to close any blocks:
    #
    #   - if Slim.awesome?
    #     | But of course it is!
    #
    # However, the parser is not smart enough (and that's a good thing) to
    # automatically insert end's where they are needed. Luckily, this filter
    # does *exactly* that (and it does it well!)
    #
    # @api private
    class EndInserter < Filter
      IF_RE = /\A(if|begin|unless|else|elsif|when|rescue|ensure)\b|\bdo\s*(\|[^|]*\|)?\s*$/
      ELSE_RE = /\A(else|elsif|when|rescue|ensure)\b/
      END_RE = /\Aend\b/

      # Handle multi expression `[:multi, *exps]`
      #
      # @return [Sexp] Corrected Temple expression with ends inserted
      def on_multi(*exps)
        @self.clear
        @self.concat(@key)

        # This variable is true if the previous line was
        # (1) a control code and (2) contained indented content.
        prev_indent = false

        exps.each do |exp|
          if control?(exp)
            code_frags = exp[2].last
            statement = code_frags.last.value
            raise(Temple::FilterError, "Explicit end statements are forbidden") if END_RE.match?(statement)

            # Two control code in a row. If this one is *not*
            # an else block, we should close the previous one.
            if prev_indent && statement !~ ELSE_RE
              @self << Sexp.new(:code, "end", start: prev_indent.start, finish: prev_indent.start)
            end

            # Indent if the control code starts a block.
            prev_indent = (statement =~ IF_RE) && exp
          elsif prev_indent
            # This is *not* a control code, so we should close the previous one.
            # Ignores newlines because they will be inserted after each line.
            @self << Sexp.new(:code, "end", start: prev_indent.start, finish: prev_indent.start)
            prev_indent = false
          end

          @self << compile(exp)
        end

        # The last line can be a control code too.
        if prev_indent
          @self << Sexp.new(:code, "end", start: prev_indent.start, finish: prev_indent.start)
        end

        @self
      end

      private

      # Checks if an expression is a Slim control code
      def control?(exp)
        exp[0].value == :slim && exp[1].value == :control
      end

      # Checks if an expression is Slim embedded code
      def embedded?(exp)
        exp[0].value == :slim && exp[1].value == :embedded
      end
    end
  end
end

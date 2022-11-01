module SlimLint
  module Filters
    # Alternative implementation of Slim::Interpolation that operates without
    # destroying the Sexp position data.
    #
    # @api private
    class Interpolation < Filter
      # Handle interpolate expression `[:slim, :interpolate, string]`
      #
      # @param [String] string Static interpolate
      # @return [Array] Compiled temple expression
      def on_slim_interpolate(string)
        # Interpolate variables in text (#{variable}).
        # Split the text into multiple dynamic and static parts.
        block = Sexp.new(:multi, start: @self.start, finish: @self.finish)
        line, column = string.start
        string = string.to_s
        loop do
          case string
          when /\A\\#\{/
            # Escaped interpolation
            block << Sexp.new(:static, '#{', start: [line, column], finish: [line, (column += 2)])
            string = $'
          when /\A#\{((?>[^{}]|(\{(?>[^{}]|\g<1>)*\}))*)\}/
            # Interpolation
            _, string, code = $&, $', $1
            escape = code !~ /\A\{.*\}\Z/

            column += 2
            unless escape
              code = code[1..-2]
              column += 1
            end

            start = [line, column]
            finish = [line, column + code.size]

            block << Sexp.new(
              :slim,
              :output,
              escape,
              Sexp.new(
                :multi,
                Sexp.new(:interpolated, code, start: start, finish: finish),
                start: start,
                finish: finish
              ),
              Sexp.new(:multi, start: start, finish: finish),
              start: start,
              finish: finish
            )

            column += code.size + 1
            column += 1 unless escape
          when /\A([#\\]?[^#\\]*([#\\][^\\{#][^#\\]*)*)/
            # Static text
            text, string = $&, $'
            text_lines = text.count("\n")

            block << Sexp.new(:static, text, start: [line, column], finish: [(line + text_lines), (text_lines == 0 ? column + text.size : 1)])

            line += text_lines
            column = (text_lines == 0 ? column + text.size : 1)
          end

          break if string.empty?
        end

        block
      end
    end
  end
end

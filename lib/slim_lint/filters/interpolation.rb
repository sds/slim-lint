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
        string = string.to_s
        line, column = @self.start
        begin
          case string
          when /\A\\#\{/
            # Escaped interpolation
            block << Sexp.new(:static, '#{', start: [line, column], finish: [line, (column += 2)])
            string = $'
          when /\A#\{((?>[^{}]|(\{(?>[^{}]|\g<1>)*\}))*)\}/
            # Interpolation
            match, string, code = $&, $', $1
            escape = code !~ /\A\{.*\}\Z/
            code = code[1..-2] unless escape

            match_lines = match.count("\n")
            code_lines = code.count("\n")

            nested = Sexp.new(:multi, start: [line, column], finish: [line, column])
            block << Sexp.new(:slim, :output, escape, Atom.new(code, pos: [line, column + (escape ? 0 : 1)]), nested, start: [line, column], finish: [(line + match_lines), (match_lines == 0 ? column + match.size : 1)])

            line += match_lines
            column = (match_lines == 0 ? column + match.size : 1)
          when /\A([#\\]?[^#\\]*([#\\][^\\#\{][^#\\]*)*)/
            # Static text
            text, string = $&, $'
            text_lines = text.count("\n")

            block << Sexp.new(:static, text, start: [line, column], finish: [(line + text_lines), (text_lines == 0 ? column + text.size : 1)])

            line += text_lines
            column = (text_lines == 0 ? column + text.size : 1)
          end
        end until string.empty?

        block
      end
    end
  end
end

module SlimLint
  # This version of the Slim::Parser makes the smallest changes it can to
  # preserve newline informatino through the parse. This helps us keep better
  # track of line numbers.
  class Parser < Slim::Parser
    @options = Slim::Parser.options

    def call(str)
      reset(str.split(/\r?\n/))
      push sexp(:multi, start: [1, 1])

      parse_line while next_line
      result = pop until @stacks.empty?

      reset
      result
    end

    def append(sexp)
      @stacks.last << sexp
    end

    def push(sexp)
      @stacks << sexp
    end

    def pop
      @stacks.last.finish = pos
      @stacks.pop
    end

    def reset(lines = nil)
      # Since you can indent however you like in Slim, we need to keep a list
      # of how deeply indented you are. For instance, in a template like this:
      #
      #   doctype       # 0 spaces
      #   html          # 0 spaces
      #    head         # 1 space
      #       title     # 4 spaces
      #
      # indents will then contain [0, 1, 4] (when it's processing the last line.)
      #
      # We uses this information to figure out how many steps we must "jump"
      # out when we see an de-indented line.
      @indents = []

      # Whenever we want to output something, we'll *always* output it to the
      # last stack in this array. So when there's a line that expects
      # indentation, we simply push a new stack onto this array. When it
      # processes the next line, the content will then be outputted into that
      # stack.
      @stacks = []

      @lineno = 0
      @lines = lines
      @prev_line = @line = @orig_line = nil
    end

    def next_line
      @prev_line = @orig_line
      if @lines.empty?
        @orig_line = @line = nil
      else
        @orig_line = @lines.shift
        @lineno += 1
        @line = @orig_line.dup
      end
    end

    protected

    def parse_line
      if @line =~ /\A\s*\Z/
        @line = $'
        append sexp(:newline)
        return
      end

      indent = get_indent(@line)

      # Choose first indentation yourself
      if @indents.empty?
        @indents << indent
      end

      # Remove the indentation
      @line.lstrip!

      # If there's more stacks than indents, it means that the previous
      # line is expecting this line to be indented.
      expecting_indentation = @stacks.size > @indents.size

      if indent > @indents.last
        # This line was actually indented, so we'll have to check if it was
        # supposed to be indented or not.
        syntax_error!('Unexpected indentation') unless expecting_indentation

        @indents << indent
      else
        # This line was *not* indented more than the line before,
        # so we'll just forget about the stack that the previous line pushed.
        pop if expecting_indentation

        # This line was deindented.
        # Now we're have to go through the all the indents and figure out
        # how many levels we've deindented.
        while indent < @indents.last && @indents.size > 1
          @indents.pop
          pop
        end

        # This line's indentation happens to lie "between" two other line's
        # indentation:
        #
        #   hello
        #       world
        #     this      # <- This should not be possible!
        syntax_error!('Malformed indentation') if indent != @indents.last
      end

      case @line
      when /\A\/!( ?)/
        # HTML comment
        comment = sexp(:html, :comment)

        @line = $'
        text = sexp(:slim, :text, :verbatim)
        capture(text) { parse_text_block(@line, @indents.last + $1.size + 2) }
        contains(comment, text)

        append comment
      when /\A\/(\[\s*(.*?)\s*\])\s*\Z/
        # HTML conditional comment
        block = sexp(:multi)

        @line.slice!(0)
        comment = sexp(:html, :condcomment, $2, width: $1.length)
        contains(comment, block)

        append comment
        push block
      when /\A\//
        # Slim comment
        parse_comment_block
      when /\A([\|'])( ?)/
        # Found verbatim text block.
        trailing_ws = $1 == "'"
        text = sexp(:slim, :text, :verbatim)
        @line = $'
        capture(text) { parse_text_block(@line, @indents.last + $2.size + 1) }

        append text
        append sexp(:static, ' ') if trailing_ws
      when /\A</
        # Inline html
        block = sexp(:multi)
        html = sexp(:multi)
        interpolation = sexp(:slim, :interpolate)
        capture(interpolation) { @line.tap { @line = "" } }
        contains(html, interpolation)
        contains(html, block)

        append html
        push block
      when /\A-/
        # Found a code block.
        # We expect the line to be broken or the next line to be indented.
        @line = $'
        block = sexp(:multi)
        statement = sexp(:slim, :control)
        capture(statement) { parse_broken_line }
        contains(statement, block)

        append statement
        push block
      when /\A=(=?)(['<>]*)/
        # Found an output block.
        # We expect the line to be broken or the next line to be indented.
        @line = $'
        trailing_ws = $2.include?('>'.freeze)
        if $2.include?('\''.freeze)
          deprecated_syntax '=\' for trailing whitespace is deprecated in favor of =>'
          trailing_ws = true
        end

        block = sexp(:multi)
        statement = sexp(:slim, :output, $1.empty?)
        capture(statement) { parse_broken_line }
        contains(statement, block)

        append sexp(:static, ' ') if $2.include?('<'.freeze)
        append statement
        append sexp(:static, ' ') if trailing_ws
        push block
      when @embedded_re
        # Embedded template detected. It is treated as block.
        @line = $2
        block = sexp(:slim, :embedded, $1)
        capture(block) { parse_text_block($', @orig_line.size - $'.size + $2.size) }
        capture(block) { parse_attributes }

        append block
      when /\Adoctype\b/
        # Found doctype declaration
        append sexp(:html, :doctype, $'.strip)
      when @tag_re
        # Found a HTML tag.
        @line = $' if $1
        parse_tag($&)
      else
        unknown_line_indicator
      end

      append sexp(:newline)
    end

    # Unknown line indicator found. Overwrite this method if
    # you want to add line indicators to the Slim parser.
    # The default implementation throws a syntax error.
    def unknown_line_indicator
      syntax_error! 'Unknown line indicator'
    end

    def parse_comment_block
      while !@lines.empty? && (@lines.first =~ /\A\s*\Z/ || get_indent(@lines.first) > @indents.last)
        next_line
        append sexp(:newline)
      end
    end

    def parse_text_block(first_line = nil, text_indent = nil)
      result = sexp(:multi)
      if !first_line || first_line.empty?
        text_indent = nil
      else
        result << sexp(:slim, :interpolate, first_line, width: first_line.size)
        @line = ""
      end

      empty_lines = 0
      first_empty = pos
      until @lines.empty?
        if @lines.first =~ /\A\s*\Z/
          next_line
          result << sexp(:newline)
          empty_lines += 1 if text_indent
        else
          indent = get_indent(@lines.first)
          break if indent <= @indents.last

          if empty_lines > 0
            result << sexp(:slim, :interpolate, "\n" * empty_lines, start: pos, lines: empty_lines, width: @line.length + 1)
            empty_lines = 0
            first_empty = pos
          end

          next_line
          @line.lstrip!

          # The text block lines must be at least indented
          # as deep as the first line.
          offset = text_indent ? indent - text_indent : 0
          if offset < 0
            text_indent += offset
            offset = 0
          end
          result << sexp(:newline) << sexp(:slim, :interpolate, (text_indent ? "\n" : '') + (' ' * offset) + @line)

          # The indentation of first line of the text block
          # determines the text base indentation.
          text_indent ||= indent
        end
      end

      result.finish = pos
      result
    end

    def parse_broken_line
      # broken_line = @line.strip
      # while broken_line =~ /[,\\]\Z/
      #   expect_next_line
      #   broken_line << "\n" << @line
      # end
      # broken_line

      ws = @orig_line[/\A[ \t]*/].size
      leader = column - ws - 1
      indent = @indents.last + leader + get_indent(@line)

      broken_line = [[@line.strip, indent]]
      while broken_line.last[0] =~ /[,\\]\Z/
        expect_next_line
        broken_line << [@line.strip, get_indent(@line)]
      end

      min = broken_line.map(&:last).min
      broken_line.each { |pair| pair[1] -= min }
      broken_line.map! { |line, indent| (" " * indent) << line }
      broken_line.join("\n")
    end

    def parse_tag(tag)
      if @tag_shortcut[tag]
        @line.slice!(0, tag.size) unless @attr_shortcut[tag]
        tag = @tag_shortcut[tag]
      end

      # Find any shortcut attributes
      attributes = sexp(:html, :attrs)
      while @line =~ @attr_shortcut_re
        # The class/id attribute is :static instead of :slim :interpolate,
        # because we don't want text interpolation in .class or #id shortcut
        syntax_error!('Illegal shortcut') unless shortcut = @attr_shortcut[$1]
        shortcut.each {|a| attributes << sexp(:html, :attr, a, sexp(:static, $2)) }
        if additional_attr_pairs = @additional_attrs[$1]
          additional_attr_pairs.each do |k,v|
            attributes << sexp(:html, :attr, k.to_s, sexp(:static, v))
          end
        end
        @line = $'
      end

      @line =~ /\A[<>']*/
      @line = $'
      trailing_ws = $&.include?('>'.freeze)
      if $&.include?('\''.freeze)
        deprecated_syntax 'tag\' for trailing whitespace is deprecated in favor of tag>'
        trailing_ws = true
      end

      leading_ws = $&.include?('<'.freeze)

      parse_attributes(attributes)

      tag = sexp(:html, :tag, tag, attributes)

      append sexp(:static, ' ') if leading_ws
      append tag
      append sexp(:static, ' ') if trailing_ws

      case @line
      when /\A\s*:\s*/
        # Block expansion
        @line = $'
        if @line =~ @embedded_re

          # Parse attributes
          @line = $2
          attrs = parse_attributes
          tag << sexp(:slim, :embedded, $1, parse_text_block($', @orig_line.size - $'.size + $2.size), attrs)
        else
          (@line =~ @tag_re) || syntax_error!('Expected tag')
          @line = $' if $1
          content = sexp(:multi)
          tag << content
          # i = @stacks.size
          push content
          parse_tag($&)
          pop
          # @stacks.delete_at(i)
        end
      when /\A\s*=(=?)(['<>]*)/
        # Handle output code
        @line = $'
        trailing_ws2 = $2.include?('>'.freeze)
        if $2.include?('\''.freeze)
          deprecated_syntax '=\' for trailing whitespace is deprecated in favor of =>'
          trailing_ws2 = true
        end
        block = sexp(:multi)
        statement = sexp(:slim, :output, $1 != '=')
        capture(statement) { parse_broken_line }
        contains(statement, block)

        @stacks.last.insert(-2, sexp(:static, ' ')) if !leading_ws && $2.include?('<'.freeze)
        tag << statement
        append sexp(:static, ' ') if !trailing_ws && trailing_ws2
        push block
      when /\A\s*\/\s*/
        # Closed tag. Do nothing
        @line = $'
        syntax_error!('Unexpected text after closed tag') unless @line.empty?
      when /\A\s*\Z/
        # Empty content
        content = sexp(:multi)
        tag << content
        push content
      when /\A ?/
        # Text content
        tag << sexp(:slim, :text, :inline)
        tag.last << parse_text_block($', @orig_line.size - $'.size)
        tag.last.finish = pos
      end
    end

    def parse_attributes(attributes = sexp(:html, :attrs))
      # Check to see if there is a delimiter right after the tag name
      delimiter = nil
      if @line =~ @attr_list_delims_re
        delimiter = @attr_list_delims[$1]
        @line = $'
      end

      if delimiter
        boolean_attr_re = /#{@attr_name}(?=(\s|#{Regexp.escape delimiter}|\Z))/
        end_re = /\A\s*#{Regexp.escape delimiter}/
      end

      while true
        case @line
        when @splat_attrs_regexp
          # Splat attribute
          @line = $'
          splat = sexp(:slim, :splat)
          capture(splat) { parse_ruby_code(delimiter) }
          attributes << splat
        when @quoted_attr_re
          # Value is quoted (static)
          attr = sexp(:html, :attr, $1)
          @line = $'
          capture(attr) do
            capture(sexp(:escape, $2.empty?)) do
              capture(sexp(:slim, :interpolate)) do
                parse_quoted_attribute($3)
              end
            end
          end
          attributes << attr
        when @code_attr_re
          # Value is ruby code
          @line = $'
          name = $1
          escape = $2.empty?
          value = ""
          attr_value = sexp(:slim, :attrvalue, escape)
          capture(attr_value) { value = parse_ruby_code(delimiter) }
          syntax_error!('Invalid empty attribute') if value.empty?
          attributes << sexp(:html, :attr, name, attr_value)
        else
          break unless delimiter

          case @line
          when boolean_attr_re
            # Boolean attribute
            @line = $'
            attributes << sexp(:html, :attr, $1, sexp(:multi))
          when end_re
            # Find ending delimiter
            @line = $'
            break
          else
            # Found something where an attribute should be
            @line.lstrip!
            syntax_error!('Expected attribute') unless @line.empty?

            # Attributes span multiple lines
            append sexp(:newline)
            syntax_error!("Expected closing delimiter #{delimiter}") if @lines.empty?
            next_line
          end
        end
      end

      # attributes || [:html, :attrs]
      attributes
    end

    def parse_ruby_code(outer_delimiter)
      code, count, delimiter, close_delimiter = '', 0, nil, nil

      # Attribute ends with space or attribute delimiter
      end_re = /\A[\s#{Regexp.escape outer_delimiter.to_s}]/

      until @line.empty? || (count == 0 && @line =~ end_re)
        if @line =~ /\A[,\\]\Z/
          code << @line << "\n"
          expect_next_line
          @line.strip!
        else
          if count > 0
            if @line[0] == delimiter[0]
              count += 1
            elsif @line[0] == close_delimiter[0]
              count -= 1
            end
          elsif @line =~ @code_attr_delims_re
            count = 1
            delimiter, close_delimiter = $&, @code_attr_delims[$&]
          end
          code << @line.slice!(0)
        end
      end
      syntax_error!("Expected closing delimiter #{close_delimiter}") if count != 0
      code
    end

    def parse_quoted_attribute(quote)
      value, count = '', 0

      until count == 0 && @line[0] == quote[0]
        if @line =~ /\A(\\)?\Z/
          value << ($1 ? ' ' : "\n")
          expect_next_line
          @line.strip!
        else
          if @line[0] == ?{
            count += 1
          elsif @line[0] == ?}
            count -= 1
          end
          value << @line.slice!(0)
        end
      end

      @line.slice!(0)
      value
    end

    # Helper for raising exceptions
    def syntax_error!(message)
      raise SyntaxError.new(message, options[:file], @orig_line, @lineno, column)
    rescue SyntaxError => ex
      # HACK: Manipulate stacktrace for Rails and other frameworks
      # to find the right file.
      ex.backtrace.unshift "#{options[:file]}:#{@lineno}"
      raise
    end

    def deprecated_syntax(message)
      line = @orig_line.lstrip
      warn %{Deprecated syntax: #{message}
  #{options[:file]}, Line #{@lineno}, Column #{column}
    #{line}
    #{' ' * column}^
}
    end

    def expect_next_line
      next_line || syntax_error!('Unexpected end of file')
      # @line.strip!
      @line
    end

    def pos
      [@lineno, column]
    end

    def column
      1 + (@orig_line&.size || 0) - (@line&.size || 0)
    end

    def sexp(*args, start: pos, width: nil, lines: 0)
      finish = [start[0] + lines, start[1] + width] if width
      Sexp.new(*args, start: start, finish: finish)
    end

    def atom(value, pos: nil)
      Atom.new(value, pos: pos || self.pos)
    end

    def capture(sexp)
      start = pos
      yielded = yield
      yielded = Atom.new(yielded, pos: start) unless yielded.is_a?(Sexp)

      sexp << yielded
      sexp.finish = pos
      sexp
    end

    def contains(container, content)
      container << content
      container.define_singleton_method(:finish) { last.finish }
    end
  end
end

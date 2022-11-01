# frozen_string_literal: true

module SlimLint
  # Utility class for extracting Ruby script from a Slim template that can then
  # be linted with a Ruby linter (i.e. is "legal" Ruby).
  #
  # The goal is to turn this:
  #
  #    - if items.any?
  #      table#items
  #      - for item in items
  #        tr
  #          td.name = item.name
  #          td.price = item.price
  #    - else
  #       p No items found.
  #
  # into (something like) this:
  #
  #    if items.any?
  #      for item in items
  #        puts item.name
  #        puts item.price
  #    else
  #      puts 'No items found'
  #    end
  #
  # The translation won't be perfect, and won't make any real sense, but the
  # relationship between variable declarations/uses and the flow control graph
  # will remain intact.
  class RubyExtractor
    include SexpVisitor
    extend SexpVisitor::DSL

    # Stores the extracted source and a map of lines of generated source to the
    # original source that created them.
    #
    # @attr_reader source [String] generated source code
    # @attr_reader source_map [Hash] map of line numbers from generated source
    #   to original source line number
    RubySource = Struct.new(:source, :source_map)

    # Extracts Ruby code from Sexp representing a Slim document.
    #
    # @param sexp [SlimLint::Sexp]
    # @return [SlimLint::RubyExtractor::RubySource]
    def extract(sexp)
      trigger_pattern_callbacks(sexp)
      RubySource.new(@source_lines.join("\n") + "\n", @source_map)
    end

    on_start do |_sexp|
      @source_lines = []
      @source_map = {}
      @line_count = 0
      @indent = 0
      @dummy_puts_count = 0
    end

    on [:html, :doctype] do |sexp|
      append_dummy_puts(sexp)
    end

    on [:html, :tag] do |sexp|
      append_dummy_puts(sexp)
    end

    on [:html, :attr] do |sexp|
      _, _, attr, value = sexp
      append("attribute(#{attr.value.inspect}) do", attr)
      @indent += 1
      traverse(value)
      @indent -= 1
      append("end", attr)
      :stop
    end

    on [:html, :comment] do |sexp|
      append_dummy_puts(sexp)
      :stop
    end

    on [:html, :condcomment] do |sexp|
      append_dummy_puts(sexp)
      :stop
    end

    on [:slim_lint, :indent] do |sexp|
      @indent += 1
    end

    on [:slim_lint, :outdent] do |sexp|
      @indent -= 1
    end

    on [:static] do |sexp|
      append_dummy_puts(sexp)
    end

    on [:dynamic] do |sexp|
      _, ruby = sexp
      append("output do", sexp)
      @indent += 1
      traverse_children(ruby)
      @indent -= 1
      append("end", sexp)
      :stop
    end

    on [:interpolated] do |sexp|
      _, ruby = sexp
      append_interpolated(ruby, sexp)
    end

    on [:code] do |sexp|
      _, ruby = sexp
      append(ruby.value, sexp)
    end

    on [:slim, :embedded] do |sexp|
      _, _, name, body, _attrs = sexp

      if name == "ruby"
        body.drop(1).each do |subexp|
          if subexp[0] == :static
            append(subexp[1].value, subexp)
          end
        end
      else
        append_dummy_puts(sexp)
      end

      :stop
    end

    private

    # Append code to the buffer.
    #
    # @param code [String]
    # @param sexp [SlimLint::Sexp]
    def append(code, sexp)
      raise "Unexpected newline!" if code.match?(/\n/)

      @source_lines << code.dup
      @line_count += 1

      if code.empty?
        @source_map[@line_count] = sexp.location
      else
        @source_lines.last.prepend("  " * @indent)
        @source_map[@line_count] = sexp.location.adjust(column: -2 * @indent)
      end
    end

    def append_dynamic(code, sexp)
      return if code.empty?
      @source_lines << "#{"  " * @indent}p #{code}"
      @line_count += 1
      @source_map[@line_count] = sexp.location.adjust(column: (-2 * @indent) - 2)
    end

    def append_interpolated(code, sexp)
      return if code.empty?
      @source_lines << %(#{"  " * @indent}p "x\#{#{code}}x")
      @line_count += 1
      @source_map[@line_count] = code.location.adjust(column: (-2 * @indent) - 6)
    end

    def append_dummy_puts(sexp)
      append("_slim_lint_puts_#{@dummy_puts_count}", sexp)
      @dummy_puts_count += 1
    end
  end
end

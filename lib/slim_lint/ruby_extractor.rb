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

    # Map of generated Ruby source code lines and their corresponding lines in
    # the original document.
    attr_reader :source_map

    # Extracts Ruby code from Sexp representing a Slim document.
    #
    # @param sexp [SlimLint::Sexp]
    def extract(sexp)
      trigger_pattern_callbacks(sexp)
      @source_lines.join("\n")
    end

    on_start do |_sexp|
      @source_lines = []
      @source_map = {}
      @line_count = 0
    end

    on [:html, :doctype] do |sexp|
      append('puts', sexp)
    end

    on [:html, :tag] do |sexp|
      append('puts', sexp)
    end

    on [:static] do |sexp|
      append('puts', sexp)
    end

    on [:dynamic] do |sexp|
      _, ruby = sexp
      append(ruby, sexp)
    end

    on [:code] do |sexp|
      _, ruby = sexp
      append(ruby, sexp)
    end

    private

    # Append code to the buffer.
    #
    # @param code [String]
    # @param sexp [SlimLint::Sexp]
    def append(code, sexp)
      return if code.empty?

      @source_lines << code
      original_line = sexp.line

      # For code that spans multiple lines, the resulting code will span
      # multiple lines, so we need to create a mapping for each line.
      (code.count("\n") + 1).times do
        @line_count += 1
        @source_map[@line_count] = original_line
      end
    end
  end
end

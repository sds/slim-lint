# frozen_string_literal: true

module SlimLint
  # Checks for unnecessary uses of the `div` tag where a class name or ID
  # already implies a div.
  class Linter::RedundantDiv < Linter
    include LinterRegistry
    support_autocorrect

    MESSAGE = '`div` is redundant when %s attribute shortcut is present'

    on [:html, :tag, 'div',
         [:html, :attrs,
           [:html, :attr,
             capture(:attr_name, anything),
             [:static]]]] do |sexp|
      attr = captures[:attr_name]
      next unless %w[class id].include?(attr)

      report_lint(sexp, MESSAGE % attr,
                  correction: correction_for(sexp.line))
    end

    private

    def correction_for(line_number)
      pattern = /\bdiv(?=[.#])/
      line = document.source_lines[line_number - 1]
      # A line number alone cannot distinguish the tag from a matching attribute.
      return unless line&.scan(pattern)&.one?

      ->(source_line) { source_line.sub(pattern, '') }
    end
  end
end

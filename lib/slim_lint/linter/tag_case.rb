# frozen_string_literal: true

module SlimLint
  # Searches for tags with uppercase characters.
  class Linter::TagCase < Linter
    include LinterRegistry
    support_autocorrect

    on_start do |sexp|
      :stop if xml_document?(sexp)
    end

    on [:html, :tag] do |sexp|
      _, _, name = sexp
      next unless name[/[A-Z]/]

      report_lint(sexp, "Tag `#{name}` should be written as `#{name.downcase}`",
                  correction: correction_for(name, sexp.line))
    end

    private

    def correction_for(name, line_number)
      pattern = /\b#{Regexp.escape(name.to_s)}\b/
      line = document.source_lines[line_number - 1]
      # A line number alone cannot distinguish the tag from a matching attribute.
      return unless line&.scan(pattern)&.one?

      ->(source_line) { source_line.sub(pattern, name.downcase) }
    end

    # XML tag names are case-sensitive (e.g. `pubDate` in RSS feeds), but an
    # XHTML document also declares an HTML doctype next to `doctype xml`
    def xml_document?(sexp)
      doctypes = sexp.select { |node| node.match?([:html, :doctype]) }
                     .map { |node| node[2].to_s }

      doctypes.any? && doctypes.all? { |doctype| doctype.match?(/\Axml(\s|\z)/i) }
    end
  end
end

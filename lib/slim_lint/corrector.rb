# frozen_string_literal: true

module SlimLint
  # Applies the corrections attached to a set of lints to a document's
  # source, producing the corrected source text.
  class Corrector
    # @param document [SlimLint::Document] document the lints were reported against
    def initialize(document)
      @document = document
    end

    # Applies every correctable lint's correction to the document's source
    # and marks each applied lint as corrected.
    #
    # A correction maps the current text of its line to the corrected text:
    # returning `nil` removes the line entirely, and returning a string
    # containing embedded newlines replaces the line with multiple lines.
    # Corrections are applied from the last line to the first so that a
    # correction which adds or removes lines never invalidates the line
    # numbers of corrections still waiting to be applied.
    #
    # @param lints [Array<SlimLint::Lint>]
    # @return [String] the corrected source
    def correct(lints)
      # `-1` keeps a trailing empty element when the source ends with a
      # newline, so the array can be joined back with "\n" to exactly
      # reproduce the source (including its trailing newline, or lack of one).
      lines = @document.source.split("\n", -1)

      correction_groups(lints).each do |line_number, line_lints|
        index = line_number - 1
        next unless index.between?(0, lines.length - 1)

        lines[index, 1] = apply_corrections(lines[index], line_lints)
      end

      @document.source_prefix + lines.join("\n")
    end

    private

    # Groups correctable lints by line number, ordered from the last line to
    # the first, so that a correction which adds or removes lines never
    # invalidates the line numbers of corrections still waiting to be applied.
    #
    # @param lints [Array<SlimLint::Lint>]
    # @return [Array<(Integer, Array<SlimLint::Lint>)>]
    def correction_groups(lints)
      lints.select(&:correctable?).group_by(&:line).sort_by { |line_number, _| -line_number }
    end

    # @param line [String] current text of the line
    # @param line_lints [Array<SlimLint::Lint>] lints reported on this line
    # @return [Array<String>] replacement line(s) for this line, possibly empty
    def apply_corrections(line, line_lints)
      line_lints.each do |lint|
        break if line.nil?

        line = lint.correction.call(line)
        lint.corrected = true
      end

      line.nil? ? [] : line.split("\n", -1)
    end
  end
end

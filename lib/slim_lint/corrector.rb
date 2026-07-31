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
    # @param lints [Array<SlimLint::Lint>]
    # @return [String] the corrected source
    def correct(lints)
      lines = @document.source_lines.dup

      lints.select(&:correctable?).group_by(&:line).each do |line_number, line_lints|
        index = line_number - 1
        next unless lines[index]

        line_lints.each do |lint|
          lines[index] = lint.correction.call(lines[index])
          lint.corrected = true
        end
      end

      corrected_source(lines)
    end

    private

    # @param lines [Array<String>]
    # @return [String]
    def corrected_source(lines)
      source = lines.join("\n")
      source += "\n" if @document.source.end_with?("\n")
      source
    end
  end
end

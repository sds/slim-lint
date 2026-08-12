# frozen_string_literal: true

module SlimLint
  class Linter::Zwsp < Linter
    include LinterRegistry
    support_autocorrect

    MSG = 'Remove zero-width space'

    on_start do |_sexp|
      dummy_node = Struct.new(:line)
      document.source_lines.each_with_index do |line, index|
        next unless line.include?("\u200b")

        report_lint(dummy_node.new(index + 1), MSG,
                    correction: ->(source_line) { source_line.delete("\u200b") })
      end
    end
  end
end

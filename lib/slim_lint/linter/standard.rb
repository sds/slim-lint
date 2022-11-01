# frozen_string_literal: true

require "slim_lint/ruby_extractor"
require "slim_lint/ruby_extract_engine"

module SlimLint
  class Linter
    # Runs RuboCop on Ruby code extracted from Slim templates.
    class Standard < RuboCop
      include LinterRegistry

      def initialize(*args)
        require "standard"
        super
      end

      private

      # Executes RuboCop against the given Ruby code and records the offenses as
      # lints.
      #
      # @param ruby [String] Ruby code
      # @param source_map [Hash] map of Ruby code line numbers to original line
      #   numbers in the template
      def find_lints(ruby, source_map)
        filename = document.file ? "#{document.file}.rb" : "ruby_script.rb"

        with_ruby_from_stdin(ruby) do
          extract_lints_from_offenses(lint_file(filename), source_map)
        end
      end

      # Defined so we can stub the results in tests
      #
      # @param file [String]
      # @return [Array<RuboCop::Cop::Offense>]
      def lint_file(filename)
        ::Standard::Cli.new(rubocop_flags << filename).run
        OffenseCollector.offenses
      end

      # Aggregates RuboCop offenses and converts them to {SlimLint::Lint}s
      # suitable for reporting.
      #
      # @param offenses [Array<RuboCop::Cop::Offense>]
      # @param source_map [Hash]
      def extract_lints_from_offenses(offenses, source_map)
        offenses.each do |offense|
          @lints << Lint.new(
            [self, offense.cop_name],
            document.file,
            location_for_line(source_map, offense),
            offense.message.gsub(/ at \d+, \d+/, "")
          )
        end
      end

      # Returns flags that will be passed to RuboCop CLI.
      #
      # @return [Array<String>]
      def rubocop_flags
        flags = %w[--format SlimLint::Linter::RuboCop::OffenseCollector]
        flags += ["--no-display-cop-names"]
        flags += ["--stdin"]
        flags
      end
    end
  end
end

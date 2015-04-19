require 'slim_lint/ruby_extractor'
require 'slim_lint/ruby_extract_engine'
require 'rubocop'
require 'tempfile'

module SlimLint
  # Runs RuboCop on Ruby code extracted from Slim templates.
  class Linter::RuboCop < Linter
    include LinterRegistry

    on_start do |_sexp|
      processed_sexp = SlimLint::RubyExtractEngine.new.call(document.source)

      extractor = SlimLint::RubyExtractor.new
      extracted_ruby = extractor.extract(processed_sexp)

      find_lints(extractor, extracted_ruby) unless extracted_ruby.empty?
    end

    private

    def find_lints(extractor, ruby)
      rubocop = ::RuboCop::CLI.new

      original_filename = document.file || 'ruby_script'
      filename = "#{File.basename(original_filename)}.slim_lint.tmp"
      directory = File.dirname(original_filename)

      Tempfile.open(filename, directory) do |f|
        begin
          f.write(ruby)
          f.close
          extract_lints_from_offences(lint_file(rubocop, f.path), extractor)
        ensure
          f.unlink
        end
      end
    end

    # Defined so we can stub the results in tests
    def lint_file(rubocop, file)
      rubocop.run(%w[--format SlimLint::OffenceCollector] << file)
      OffenceCollector.offences
    end

    def extract_lints_from_offences(offences, extractor)
      offences.select { |offence| !config['ignored_cops'].include?(offence.cop_name) }
              .each do |offence|
        @lints << Lint.new(self,
                           document.file,
                           extractor.source_map[offence.line],
                           "#{offence.cop_name}: #{offence.message}")
      end
    end
  end

  # Collects offences detected by RuboCop.
  class OffenceCollector < ::RuboCop::Formatter::BaseFormatter
    attr_accessor :offences

    class << self
      attr_accessor :offences
    end

    def started(_target_files)
      self.class.offences = []
    end

    def file_finished(_file, offences)
      self.class.offences += offences
    end
  end
end

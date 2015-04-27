module SlimLint
  # Responsible for running the applicable linters against the desired files.
  class Runner
    # Runs the appropriate linters against the desired files given the specified
    # options.
    #
    # @param options [Hash]
    # @return [SlimLint::Report] a summary of all lints found
    def run(options = {})
      config = load_applicable_config(options)
      files = extract_applicable_files(config, options)

      linter_selector = SlimLint::LinterSelector.new(config, options)

      @lints = []
      files.each do |file|
        find_lints(file, linter_selector, config)
      end

      SlimLint::Report.new(@lints, files)
    end

    private

    # Returns the {SlimLint::Configuration} that should be used given the
    # specified options.
    #
    # @param options [Hash]
    # @return [SlimLint::Configuration]
    def load_applicable_config(options)
      if options[:config_file]
        SlimLint::ConfigurationLoader.load_file(options[:config_file])
      else
        SlimLint::ConfigurationLoader.load_applicable_config
      end
    end

    # Runs all provided linters using the specified config against the given
    # file.
    #
    # @param file [String] path to file to lint
    # @param linter_selector [SlimLint::LinterSelector]
    # @param config [SlimLint::Configuration]
    def find_lints(file, linter_selector, config)
      document = SlimLint::Document.new(File.read(file), file: file, config: config)

      linter_selector.linters_for_file(file).each do |linter|
        @lints += linter.run(document)
      end
    rescue Slim::Parser::SyntaxError => ex
      @lints << SlimLint::Lint.new(nil, file, ex.line, ex.error, :error)
    end

    # Returns the list of files that should be linted given the specified
    # configuration and options.
    #
    # @param config [SlimLint::Configuration]
    # @param options [Hash]
    # @return [Array<String>]
    def extract_applicable_files(config, options)
      included_patterns = options[:files]
      excluded_files = options.fetch(:excluded_files, [])

      SlimLint::FileFinder.new(config).find(included_patterns, excluded_files)
    end
  end
end

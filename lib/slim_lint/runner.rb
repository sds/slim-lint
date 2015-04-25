module SlimLint
  # Responsible for running the applicable linters against the desired files.
  class Runner
    # List of applicable files.
    attr_reader :files

    # Runs the appropriate linters against the desired files given the specified
    # options.
    #
    # @param options [Hash]
    # @raise [SlimLint::Exceptions::NoLintersError] when no linters are enabled
    # @return [SlimLint::Report] a summary of all lints found
    def run(options = {})
      config = load_applicable_config(options)
      files = extract_applicable_files(config, options)
      linters = extract_enabled_linters(config, options)

      raise SlimLint::Exceptions::NoLintersError, 'No linters specified' if linters.empty?

      @lints = []
      files.each do |file|
        find_lints(file, linters, config)
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

    # Returns a list of linters that are enabled given the specified
    # configuration and additional options.
    #
    # @param config [SlimLint::Configuration]
    # @param options [Hash]
    # @return [Array<SlimLint::Linter>]
    def extract_enabled_linters(config, options)
      included_linters = LinterRegistry
        .extract_linters_from(options.fetch(:included_linters, []))

      included_linters = LinterRegistry.linters if included_linters.empty?

      excluded_linters = LinterRegistry
        .extract_linters_from(options.fetch(:excluded_linters, []))

      # After filtering out explicitly included/excluded linters, only include
      # linters which are enabled in the configuration
      (included_linters - excluded_linters).map do |linter_class|
        linter_config = config.for_linter(linter_class)
        linter_class.new(linter_config) if linter_config['enabled']
      end.compact
    end

    # Runs all provided linters using the specified config against the given
    # file.
    #
    # @param file [String] path to file to lint
    # @param linters [Array<SlimLint::Linter>]
    # @param config [SlimLint::Configuration]
    def find_lints(file, linters, config)
      document = SlimLint::Document.new(File.read(file), file: file, config: config)

      linters.each do |linter|
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

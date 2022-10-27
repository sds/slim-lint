# frozen_string_literal: true

module SlimLint
  # Chooses the appropriate linters to run given the specified configuration.
  class LinterSelector
    # Creates a selector using the given configuration and additional options.
    #
    # @param config [SlimLint::Configuration]
    # @param options [Hash]
    def initialize(config, options)
      @config = config
      @options = options
    end

    # Returns the set of linters to run against the given file.
    #
    # @param file [String]
    # @raise [SlimLint::Exceptions::NoLintersError] when no linters are enabled
    # @return [Array<SlimLint::Linter>]
    def linters_for_file(file)
      @linters ||= extract_enabled_linters(@config, @options)
      @linters.select { |linter| run_linter_on_file?(@config, linter, file) }
    end

    private

    # Returns a list of linter names that are enabled given the specified
    # configuration and additional options.
    #
    # @param config [SlimLint::Configuration]
    # @param options [Hash]
    # @return [Array<String>]
    def extract_enabled_linter_names(config, options)
      included_linters = options.fetch(:included_linters, [])
      included_linters = LinterRegistry.linters.map(&:name) if included_linters.empty?

      excluded_linters = options.fetch(:excluded_linters, [])

      # After filtering out explicitly included/excluded linters, only include
      # linters which are enabled in the configuration
      linters = (included_linters - excluded_linters).select do |name|
        config.for_linter(name)["enabled"]
      end

      # Highlight condition where all linters were filtered out, as this was
      # likely a mistake on the user's part
      if linters.empty?
        raise SlimLint::Exceptions::NoLintersError, "No linters specified"
      end

      linters
    end

    # Returns a list of linters that are enabled given the specified
    # configuration and additional options.
    #
    # @param config [SlimLint::Configuration]
    # @param options [Hash]
    # @return [Array<SlimLint::Linter>]
    def extract_enabled_linters(config, options)
      linter_names = extract_enabled_linter_names(config, options)
      linter_classes = LinterRegistry.extract_linters_from(linter_names)
      linter_classes.map { |klass| klass.new(config.for_linter(klass)) }
    end

    # Whether to run the given linter against the specified file.
    #
    # @param config [SlimLint::Configuration]
    # @param linter [SlimLint::Linter]
    # @param file [String]
    # @return [Boolean]
    def run_linter_on_file?(config, linter, file)
      linter_config = config.for_linter(linter)
      incl, excl = linter_config["include"], linter_config["exclude"]

      if incl.any? && !SlimLint::Utils.any_glob_matches?(incl, file)
        return false
      end

      if SlimLint::Utils.any_glob_matches?(excl, file)
        return false
      end

      true
    end
  end
end

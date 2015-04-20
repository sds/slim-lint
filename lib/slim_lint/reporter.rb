module SlimLint
  # Abstract lint reporter. Subclass and override {#report_lints} to
  # implement a custom lint reporter.
  #
  # @abstract
  class Reporter
    # List of lints that this reporter should report.
    attr_reader :lints

    # List of files that were linted.
    attr_reader :files

    # @param logger [SlimLint::Logger]
    # @param report [SlimLint::Report]
    def initialize(logger, report)
      @log = logger
      @lints = report.lints
      @files = report.files
    end

    # Implemented by subclasses to display lints from a {SlimLint::Report}.
    def report_lints
      raise NotImplementedError
    end

    # Keep tracking all the descendants of this class for the list of available
    # reporters.
    #
    # @return [Array<Class>]
    def self.descendants
      @descendants ||= []
    end

    # Executed when this class is subclassed.
    def self.inherited(descendant)
      descendants << descendant
    end

    private

    attr_reader :log
  end
end

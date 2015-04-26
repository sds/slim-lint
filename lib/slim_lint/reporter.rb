module SlimLint
  # Abstract lint reporter. Subclass and override {#report_lints} to
  # implement a custom lint reporter.
  #
  # @abstract
  class Reporter
    # @return [SlimLint::Report] report of all lints found and files scanned
    attr_reader :report

    # Creates the reporter that will display the given report.
    #
    # @param logger [SlimLint::Logger]
    # @param report [SlimLint::Report]
    def initialize(logger, report)
      @log = logger
      @report = report
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
    #
    # @param descendant [Class]
    def self.inherited(descendant)
      descendants << descendant
    end

    private

    attr_reader :log
  end
end

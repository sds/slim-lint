module SlimLint
  # Base implementation for all lint checks.
  class Linter
    # Include definitions for Sexp pattern-matching helpers.
    include SexpVisitor
    extend SexpVisitor::DSL

    # TODO: Remove once spec support returns an array of lints instead of a
    # linter
    attr_reader :lints

    # @param config [Hash] configuration for this linter
    def initialize(config)
      @config = config
      @lints = []
      @ruby_parser = nil
    end

    # Runs the linter against the specified Sexp
    def run(document)
      @document = document
      @lints = []
      trigger_pattern_callbacks(document.sexp)
      @lints
    end

    # Returns the simple name for this linter.
    def name
      self.class.name.split('::').last
    end

    private

    attr_reader :config, :document

    # Record a lint for reporting back to the user.
    def report_lint(sexp, message)
      @lints << SlimLint::Lint.new(self, @document.file, sexp.line, message)
    end

    # Parse Ruby code into an abstract syntax tree.
    #
    # @return [AST::Node]
    def parse_ruby(source)
      @ruby_parser ||= SlimLint::RubyParser.new
      @ruby_parser.parse(source)
    end
  end
end

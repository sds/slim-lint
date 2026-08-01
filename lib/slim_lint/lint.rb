# frozen_string_literal: true

module SlimLint
  # Contains information about a problem or issue with a Slim document.
  class Lint
    # @return [String] file path to which the lint applies
    attr_reader :filename

    # @return [String] line number of the file the lint corresponds to
    attr_reader :line

    # @return [SlimLint::Linter] linter that reported the lint
    attr_reader :linter

    # @return [String] error/warning message to display to user
    attr_reader :message

    # @return [Symbol] whether this lint is a warning or an error
    attr_reader :severity

    # @return [Proc, nil] maps a line of source to its corrected version, or
    #   `nil` if this lint has no known automatic correction
    attr_reader :correction

    # @return [Boolean] whether this lint's correction has been applied
    attr_accessor :corrected

    # Creates a new lint.
    #
    # @param linter [SlimLint::Linter]
    # @param filename [String]
    # @param line [Fixnum]
    # @param message [String]
    # @param severity [Symbol]
    # @param correction [Proc, nil] maps a line of source to its corrected version
    def initialize(linter, filename, line, message, severity = :warning, # rubocop:disable Metrics/ParameterLists
                   correction: nil)
      @linter     = linter
      @filename   = filename
      @line       = line || 0
      @message    = message
      @severity   = severity
      @correction = correction
      @corrected  = false
    end

    # Return whether this lint has a severity of error.
    #
    # @return [Boolean]
    def error?
      @severity == :error
    end

    # Return whether this lint has a known automatic correction.
    #
    # @return [Boolean]
    def correctable?
      !@correction.nil?
    end

    # Return whether this lint's correction has been applied.
    #
    # @return [Boolean]
    def corrected?
      @corrected
    end
  end
end

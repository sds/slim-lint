# frozen_string_literal: true

module SlimLint
  # Contains information about a problem or issue with a Slim document.
  class Lint
    # @return [String] file path to which the lint applies
    attr_reader :filename

    # @return [SourceLocation] location in the file the lint corresponds to
    attr_reader :location

    # @return [SlimLint::Linter] linter that reported the lint
    attr_reader :linter

    # @return [String] sublinter that reported the lint
    attr_reader :sublinter

    # @return [String] error/warning message to display to user
    attr_reader :message

    # @return [Symbol] whether this lint is a warning or an error
    attr_reader :severity

    # Creates a new lint.
    #
    # @param linter [SlimLint::Linter]
    # @param filename [String]
    # @param location [SourceLocation]
    # @param message [String]
    # @param severity [Symbol]
    def initialize(linter, filename, location, message, severity = :warning)
      @linter, @sublinter = Array(linter)
      @filename = filename
      @location = location
      @message = message
      @severity = severity
    end

    def line
      location.line
    end

    def column
      location.column
    end

    def last_line
      location.last_line
    end

    def last_column
      location.last_column
    end

    def cop
      @sublinter || @linter.name if @linter
    end

    def name
      [@linter.name, @sublinter].compact.join("/") if @linter
    end

    # Return whether this lint has a severity of error.
    #
    # @return [Boolean]
    def error?
      @severity == :error
    end
  end
end

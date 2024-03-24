# frozen_string_literal: true

module SlimLint
  # Thin wrapper around a parsed ruby node location that provides
  # the source-mapped line number instead of the one from the ruby source
  # extracted by SlimLint::RubyExtractor.
  class SourceMappedLocation
    # @param node [Object] The node location returned by the ruby parser
    # @param node [Hash] The source map returned by SlimLint::RubyExtractor
    def initialize(location, source_map)
      @location = location
      @source_map = source_map
    end

    # @return [Integer] the line number source-mapped from the original
    #                   Slim template
    def line
      @source_map[@location.line]
    end
  end
end

module SlimLint
  # Stores runtime configuration for the application.
  class Configuration
    # Interan hash storing the configuration.
    attr_reader :hash

    # Creates a configuration from the given options hash.
    #
    # @param options [Hash]
    def initialize(options)
      @hash = options
      validate
    end

    # Access the configuration as if it were a hash.
    #
    # @param key [String]
    # @return [Array,Hash,Number,String]
    def [](key)
      @hash[key]
    end

    # Compares this configuration with another.
    #
    # @param other [SlimLint::Configuration]
    # @return [true,false] whether the given configuration is equivalent
    def ==(other)
      super || @hash == other.hash
    end
    alias_method :eql?, :==

    # Returns a non-modifiable configuration for the specified linter.
    #
    # @param linter [SlimLint::Linter,Class]
    def for_linter(linter)
      linter_name =
        case linter
        when Class
          linter.name.split('::').last
        when SlimLint::Linter
          linter.name
        else
          linter.to_s
        end

      smart_merge(@hash['linters']['ALL'],
                  @hash['linters'].fetch(linter_name, {})).freeze
    end

    # Returns whether the specified linter is enabled by this configuration.
    #
    # @param linter [SlimLint::Linter,String]
    def linter_enabled?(linter)
      for_linter(linter)['enabled'] != false
    end

    # Merges the given configuration with this one, returning a new
    # {Configuration}. The provided configuration will either add to or replace
    # any options defined in this configuration.
    #
    # @param config [SlimLint::Configuration]
    def merge(config)
      self.class.new(smart_merge(@hash, config.hash))
    end

    private

    # Merge two hashes such that nested hashes are merged rather than replaced.
    #
    # @param paremt [Hash]
    # @param child [Hash]
    # @return [Hash]
    def smart_merge(parent, child)
      parent.merge(child) do |_key, old, new|
        case old
        when Hash
          smart_merge(old, new)
        else
          new
        end
      end
    end

    # Validates the configuration for any invalid options, normalizing it where
    # possible.
    def validate
      @hash = convert_nils_to_empty_hashes(@hash)
      ensure_linter_section_exists(@hash)
    end

    # Ensures the `linters` configuration section exists.
    def ensure_linter_section_exists(hash)
      hash['linters'] ||= {}
      hash['linters']['ALL'] ||= {}
    end

    # Convert nil values to empty hashes, as this saves us from having to check
    # for `nil`s when reading deeply-nested hashes.
    def convert_nils_to_empty_hashes(hash)
      hash.each_with_object({}) do |(key, value), h|
        h[key] =
          case value
          when nil  then {}
          when Hash then convert_nils_to_empty_hashes(value)
          else
            value
          end
        h
      end
    end
  end
end

module SlimLint
  # Holds the list of captures, providing a convenient interface for accessing
  # the values and unwrapping them on your behalf.
  class CaptureMap < Hash
    # Returns the captured value with the specified name.
    #
    # @param key [Symbol]
    # @return [Object]
    def [](key)
      if key?(key)
        super.value
      else
        raise ArgumentError, "Capture group #{key.inspect} does not exist!"
      end
    end
  end
end

module SlimLint::Matcher
  # Wraps a matcher, taking on the behavior of the wrapped matcher but storing
  # the value that matched so it can be referred to later.
  class Capture < Base
    # @return [Symbol] name of the capture
    attr_accessor :name

    # @return [SlimLint::Matcher::Base] matcher that this capture wraps
    attr_accessor :matcher

    # @see {SlimLint::Matcher::Base#match?}
    def match?(object)
      if result = matcher.match?(object)
        @context.captures[name] = object
      end

      result
    end
  end
end

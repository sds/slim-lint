module SlimLint::Matcher
  # Represents a Sexp pattern implementing complex matching logic.
  #
  # Subclasses can implement custom logic to create complex matches that can be
  # reused across linters, DRYing up matching code.
  #
  # @abstract
  class Base
    # Creates a matcher within the given Sexp traversal context.
    #
    # The context allows this matcher to store additional information as part of
    # the match that is accessible later.
    #
    # @param context [SlimLint::SexpVisitor]
    def initialize(context)
      @context = context
    end

    # Whether this matcher matches the specified object.
    #
    # This must be implemented by subclasses.
    #
    # @param other [Object]
    # @return [Boolean]
    def match?(*)
      raise NotImplementedError, 'Matcher must implement `match?`'
    end
  end
end

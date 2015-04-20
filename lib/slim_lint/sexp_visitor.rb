module SlimLint
  # Provides an interface which when included allows a class to visit nodes in
  # the Sexp of a Slim document.
  module SexpVisitor
    # Traverse the Sexp looking for matches with registered patterns, firing
    # callbacks for all matches.
    #
    # @param sexp [Sexp]
    def trigger_pattern_callbacks(sexp)
      on_start sexp
      traverse sexp
    end

    # Traverse the given Sexp, firing callbacks if they are defined.
    #
    # @param sexp [Sexp]
    def traverse(sexp)
      block_called = false

      # Define a block within the closure of this method so that pattern matcher
      # blocks can call `yield` within their block definitions to force
      # traversal of their children.
      block = ->(action = :descend) do
        block_called = true
        case action
        when Sexp
          # User explicitly yielded a Sexp, indicating they want to control the
          # flow of traversal. Traverse the Sexp they returned.
          traverse(action)
        when :descend
          traverse_children(sexp)
        end
      end

      patterns.each do |pattern|
        next unless sexp.match?(pattern.sexp)

        result = method(pattern.callback_method_name).call(sexp, &block)

        # Returning :stop indicates we should stop searching this Sexp
        # (i.e. stop descending this branch of depth-first search).
        # The `return` here is very intentional.
        return if result == :stop # rubocop:disable Lint/NonLocalExitFromIterator
      end

      # If no pattern matchers called `yield` explicitly, continue traversing
      # children by default (matchers can return `:stop` to not continue).
      traverse_children(sexp) unless block_called
    end

    def traverse_children(sexp)
      sexp.each do |nested_sexp|
        traverse nested_sexp if nested_sexp.is_a?(Sexp)
      end
    end

    # Returns the list of registered Sexp patterns.
    #
    # @return [Array<SlimLint::SexpVisitor::SexpPattern>]
    def patterns
      self.class.patterns || []
    end

    # Executed before searching for any pattern matches.
    #
    # @param sexp [SlimLint::Sexp]
    def on_start(*)
      # Overidden by DSL.on_start
    end

    # Mapping of Sexp pattern to callback method name.
    #
    # @!attribute sexp
    #   @return [Array] S-expression pattern that when matched triggers the
    #     callback
    # @!attribute callback_method_name
    #   @return [Symbol] name of the method to call when pattern is matched
    SexpPattern = Struct.new(:sexp, :callback_method_name)
    private_constant :SexpPattern

    # Exposes a convenient Domain-specific Language (DSL) that makes declaring
    # Sexp match patterns very easy.
    #
    # Include them with `extend SlimLint::SexpVisitor::DSL`
    module DSL
      # Registered patterns that this visitor will look for when traversing the
      # {SlimLint::Sexp}.
      attr_reader :patterns

      # DSL helper that defines a sexp pattern and block that will be executed if
      # the given pattern is found.
      #
      # @param sexp_pattern [Sexp]
      # @yield block to execute when the specified pattern is matched
      # @yieldparam sexp [SlimLint::Sexp] Sexp that matched the pattern
      # @yieldreturn [SlimLint::Sexp,Symbol,void]
      #   If a Sexp is returned, indicates that traversal should jump directly
      #   to that Sexp.
      #   If `:stop` is returned, halts further traversal down this branch
      #   (i.e. stops recursing, but traversal at higher levels will continue).
      #   Otherwise traversal will continue as normal.
      def on(sexp_pattern, &block)
        # TODO: Index Sexps on creation so we can quickly jump to potential
        # matches instead of checking array.
        @patterns ||= []
        @pattern_number ||= 1

        # Use a monotonically increasing number to identify the method so that in
        # debugging we can simply look at the nth defintion in the class.
        unique_method_name = :"on_pattern_#{@pattern_number}"
        define_method(unique_method_name, block)

        @pattern_number += 1
        @patterns << SexpPattern.new(sexp_pattern, unique_method_name)
      end

      # Define a block of code to run before checking for any pattern matches.
      #
      # @yield block to execute
      def on_start(&block)
        define_method(:on_start, block)
      end
    end
  end
end

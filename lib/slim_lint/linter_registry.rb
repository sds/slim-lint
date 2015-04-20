module SlimLint
  class NoSuchLinter < StandardError; end

  # Stores all defined linters.
  module LinterRegistry
    @linters = []

    class << self
      # List of all registered linters.
      attr_reader :linters

      # Executed when a linter includes the {LinterRegistry} module.
      #
      # This results in the linter being registered with the registry.
      def included(base)
        @linters << base
      end

      # Return a list of {SlimLint::Linter} {Class}es corresponding to the
      # specified list of names.
      #
      # @return [Array<Class>]
      def extract_linters_from(linter_names)
        linter_names.map do |linter_name|
          begin
            SlimLint::Linter.const_get(linter_name)
          rescue NameError
            raise NoSuchLinter, "Linter #{linter_name} does not exist"
          end
        end
      end
    end
  end
end

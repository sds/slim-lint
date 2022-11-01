# frozen_string_literal: true

module SlimLint
  module Filters
    # A dumbed-down version of {Slim::Splat::Filter} which doesn't introduced
    # temporary variables or other cruft.
    class SplatProcessor < Filter
      # Handle slim splat expressions `[:slim, :splat, code]`
      #
      # @param code [String]
      # @return [Array]
      def on_slim_splat(code)
        return code if code[0] == :multi
        @self.delete_at(1)
        @self.first.value = :code
        @self
      end
    end
  end
end

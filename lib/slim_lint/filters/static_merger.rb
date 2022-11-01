module SlimLint
  module Filters
    # Merges several statics into a single static while respecting source
    # location data.  Example:
    #
    #   [:multi,
    #     [:static, "Hello "],
    #     [:static, "World!"]]
    #
    # Compiles to:
    #
    #   [:static, "Hello World!"]
    #
    # @api public
    class StaticMerger < Filter
      def on_slim_embedded(*exps)
        @self
      end

      def on_multi(*exps)
        result = @self
        result.clear
        result.concat(@key)

        static = nil
        exps.each do |exp|
          if exp.first == :static
            if static
              static.finish = exp.finish if later_pos?(static.finish, exp.finish)
              static.last.finish = exp.finish if later_pos?(static.last.finish, exp.finish)
              static.last.value << exp.last.value
            else
              static = exp
              static[1] = exp.last.dup
              result << static
            end
          else
            result << compile(exp)
            static = nil unless exp.first == :newline
          end
        end

        result.size == 2 ? result[1] : result
      end
    end
  end
end

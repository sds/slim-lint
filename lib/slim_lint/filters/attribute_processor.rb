# frozen_string_literal: true

module SlimLint
  module Filters
    # A dumbed-down version of {Slim::CodeAttributes} which doesn't introduce any
    # temporary variables or other cruft.
    class AttributeProcessor < Filter
      define_options :merge_attrs

      # Handle attributes expression `[:html, :attrs, *attrs]`
      #
      # @param attrs [Array]
      # @return [Array]
      def on_html_attrs(*attrs)
        @self.delete_at(1)
        expr = on_multi(*attrs)
        expr[0].value = :multi
        expr
      end

      # # Handle attribute expression `[:html, :attr, name, value]`
      # #
      # # @param name [String] name of the attribute
      # # @param value [Array] Sexp representing the value
      # def on_html_attr(name, value)
      #   if value[0] == :slim && value[1] == :attrvalue
      #     code = value[3]
      #     [:code, code]
      #   else
      #     @attr = name
      #     super
      #   end
      # end

      def on_slim_attrvalue(_escape, code)
        return code if code[0] == :multi
        @self.start = code.start
        @self.finish = code.finish
        @self[0].value = :code
        @self.delete_at(2)
        @self.delete_at(1)
        @self
      end
    end
  end
end

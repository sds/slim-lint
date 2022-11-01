module SlimLint
  # Alternative implementation of Slim::Filter that operates without
  # destroying the Sexp position data.
  class Filter < Temple::HTML::Filter
    module Overrides
      def on_multi(*exps)
        exps.each.with_index(1) { |exp, i| @self[i] = compile(exp) }
        @self
      end

      def on_escape(flag, content)
        @self[2] = compile(content)
        @self
      end

      def on_html_attrs(*attrs)
        attrs.each.with_index(2) { |attr, i| @self[i] = compile(attr) }
        @self
      end

      def on_html_attr(name, content)
        @self[3] = compile(content)
        @self
      end

      def on_html_comment(content)
        @self[2] = compile(content)
        @self
      end

      def on_html_condcomment(condition, content)
        @self[3] = compile(content)
        @self
      end

      def on_html_js(content)
        @self[2] = compile(content)
        @self
      end

      def on_html_tag(name, attrs, content = nil)
        @self[3] = compile(attrs)
        @self[4] = compile(content) if content
        @self
      end

      # Pass-through handler
      def on_slim_text(type, content)
        @self[3] = compile(content)
        @self
      end

      # Pass-through handler
      def on_slim_embedded(type, content, attrs)
        @self[3] = compile(content)
        @self
      end

      # Pass-through handler
      def on_slim_control(code, content)
        @self[3] = compile(content)
        @self
      end

      # Pass-through handler
      def on_slim_output(escape, code, content)
        @self[4] = compile(content)
        @self
      end

      private

      def dispatcher(exp)
        @self_stack ||= []
        @key_stack ||= []
        @self_stack << @self
        @self = exp

        exp.size.downto(1) do |depth|
          available_methods = dispatched_methods_by_depth[depth]
          next unless available_methods

          slice = exp.take(depth)
          next unless slice.all? { |x| x.is_a?(Atom) && x.value.is_a?(Symbol) }

          name = "on_#{slice.join("_")}"
          if available_methods.include?(name)
            @key_stack << @key
            @key = slice
            return send(name, *exp.drop(depth))
          end
        end

        exp
      ensure
        @self = @self_stack.pop
        @key = @key_stack.pop
      end

      def dispatched_methods_by_depth
        @dispatched_methods_by_depth ||= dispatched_methods.group_by { |x| x.count("_") }
      end

      def empty_exp?(exp)
        case exp[0].value
        when :multi
          exp[1..].all? { |e| empty_exp?(e) }
        else
          false
        end
      end

      # Compares two [line, column] position pairs, and returns true if position
      # `a` comes before position `b`.
      #
      # @param a [Array(Int, Int)] Position `a`
      # @param b [Array(Int, Int)] Position `b`
      # @return Does position `a` occur before position `b`?
      def later_pos?(a, b)
        a[0] < b[0] || (a[0] == b[0] && a[1] < b[1])
      end
    end

    include Overrides
  end
end

module SlimLint
  # Symbolic expression which represents tree-structured data.
  #
  # The main use of this particular implementation is to provide a single
  # location for defining convenience helpers when operating on Sexps.
  class Sexp < Array
    # Stores the line number of the code in the original document that
    # corresponds to this Sexp.
    attr_accessor :line

    # Creates an {Sexp} from the given {Array}-based Sexp.
    #
    # @param array_sexp [Array]
    def initialize(array_sexp)
      array_sexp.each do |child|
        item =
          case child
          when Array
            Sexp.new(child)
          else
            child
          end

        push(item)
      end
    end

    # Returns whether this {Sexp} matches the given Sexp pattern.
    #
    # A Sexp pattern is simply an incomplete Sexp prefix.
    #
    # @example
    #   The following Sexp:
    #
    #     [:html, :doctype, "html5"]
    #
    #   ...will match the given patterns:
    #
    #     [:html]
    #     [:html, :doctype]
    #     [:html, :doctype, "html5"]
    #
    # Note that nested Sexps will also be matched, so be careful about the cost
    # of matching against a complicated pattern.
    #
    # @param sexp_pattern [Sexp]
    # @return [Boolean]
    def match?(sexp_pattern)
      # If there aren't enough items to compare then this obviously won't match
      return unless length >= sexp_pattern.length

      sexp_pattern.each_with_index do |sub_pattern, index|
        case sub_pattern
        when Array
          return false unless self[index].match?(sub_pattern)
        else
          return false unless self[index] == sub_pattern
        end
      end

      true
    end

    # Pretty-prints this Sexp in a form that is more readable.
    #
    # @param depth [Integer] indentation level to display Sexp at
    # @return [String]
    def display(depth = 1) # rubocop:disable Metrics/AbcSize
      indentation = ' ' * 2 * depth
      output = indentation
      output = '['
      output << "\n"

      each_with_index do |nested_sexp, index|
        output += indentation

        case nested_sexp
        when Sexp
          output += nested_sexp.display(depth + 1)
        else
          output += nested_sexp.inspect
        end

        if index < length - 1
          output += ",\n"
        end
      end
      output << "\n"
      output << ' ' * 2 * (depth - 1)
      output << ']'

      output
    end
  end
end

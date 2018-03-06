# frozen_string_literal: true

module IndentNormalizer
  # Strips off excess leading indentation from each line so we can use Heredocs
  # for writing code without having the leading indentation count.
  def normalize_indent(code)
    leading_indent = code[/^(\s*?)(\n|\S)/, 1]
    code.gsub(/^#{leading_indent}/, '')
  end
end

RSpec.configure do |_config|
  include IndentNormalizer
end

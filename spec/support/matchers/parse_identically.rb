# frozen_string_literal: true

RSpec::Matchers.define :parse_identically do |template|
  diffable

  match do |subject|
    @expected_as_array = [Slim::Parser.new.call(template)]
    @actual = subject.call(template).to_array
    expected == actual
  end

  failure_message do |subject|
    "expected the template to parse identically, but it did not"
  end
end

RSpec::Matchers.define :parse_identically_accounting_for_whitespace do |template|
  diffable

  match do |subject|
    @expected_as_array = [Slim::Parser.new.call(template)]
    @actual = subject.call(template).to_array
    expected == normalize_whitespace(actual)
  end

  failure_message do |subject|
    "expected the template to parse identically (with only whitespace differences), but it did not"
  end

  def normalize_whitespace(array)
    if array[0] == :multi
      1.upto(array.size - 1) do |idx|
        array[idx] = normalize_whitespace(array[idx])
      end
    elsif array[0] == :slim && array[1] == :control
      array[2] = array[2].lines.map(&:strip).join("\n")
    elsif array[0] == :slim && array[1] == :output
      array[3] = array[3].lines.map(&:strip).join("\n")
    end

    array
  end
end

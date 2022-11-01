# frozen_string_literal: true

RSpec::Matchers.define :match_the_offical_parser do
  diffable

  match do |subject|
    @expected_as_array = [Slim::Parser.new.call(template)]
    @actual = subject.call(template).to_array
    expected == actual
  end

  failure_message do |subject|
    "expected the template parse tree to match the official parse tree, but it did not"
  end
end

RSpec::Matchers.define :officially_parse_as do |expected|
  diffable

  match do |subject|
    @actual = Slim::Parser.new.call(template)
    expected == actual
  end

  failure_message do |subject|
    "expected the official parse tree to match, but it did not"
  end
end

RSpec::Matchers.define :parse_as do |expected|
  diffable

  match do |subject|
    @actual = subject.call(template).to_array
    expected == actual
  end

  failure_message do |subject|
    "expected our custom parse tree to match, but it did not"
  end
end

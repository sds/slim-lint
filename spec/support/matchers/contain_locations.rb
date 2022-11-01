# frozen_string_literal: true

RSpec::Matchers.define :contain_locations do |expected_locations|
  diffable

  match do |subject|
    expected_keys = expected_locations.values.map(&:keys)
    @actual = subject.transform_values { |x| x.as_json.slice(*expected_keys.shift) }
    @actual == expected_locations
  end

  failure_message do |subject|
    "expected the source map to contain the listed locations, but it did not"
  end
end

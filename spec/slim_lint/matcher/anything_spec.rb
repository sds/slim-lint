# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Matcher::Anything do
  describe "#match?" do
    it "always matches" do
      [:anything, 123, "whatever", {}].each do |other|
        subject.match?(other).should eq(true)
      end
    end
  end
end

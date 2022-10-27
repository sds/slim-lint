# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Matcher::Nothing do
  describe "#match?" do
    it "never matches" do
      [:anything, 123, "whatever", {}].each do |other|
        subject.match?(other).should eq(false)
      end
    end
  end
end

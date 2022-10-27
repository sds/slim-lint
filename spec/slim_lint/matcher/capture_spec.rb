# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Matcher::Capture do
  let(:capture) { described_class.from_matcher(matcher) }

  describe "#match?" do
    let(:other) { :anything }

    subject { capture.match?(other) }

    context "with a matcher that matches" do
      let(:matcher) { SlimLint::Matcher::Anything.new }

      it { should eq(true) }

      it "captures a value" do
        subject
        capture.value.should eq(:anything)
      end
    end

    context "with a matcher that does not match" do
      let(:matcher) { SlimLint::Matcher::Nothing.new }

      it { should eq(false) }

      it "does not capture a value" do
        subject
        capture.value.should be_nil
      end
    end
  end
end

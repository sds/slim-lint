# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Matcher::Base do
  describe "#match?" do
    let(:other) { :anything }
    subject { super().match?(other) }

    it "raises an error" do
      expect { subject }.to raise_error NotImplementedError
    end
  end
end

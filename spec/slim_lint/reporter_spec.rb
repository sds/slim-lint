# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Reporter do
  let(:reporter) { SlimLint::Reporter.new(double) }

  describe "#display_report" do
    subject { reporter.display_report(double) }

    it "raises an error" do
      expect { subject }.to raise_error NotImplementedError
    end
  end
end

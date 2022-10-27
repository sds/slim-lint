# frozen_string_literal: true

require "spec_helper"

describe SlimLint::CaptureMap do
  let(:map) do
    described_class.new.tap do |cm|
      cm[:one] = double(value: 2)
    end
  end

  describe "#[]" do
    subject { map[name] }

    context "when the capture name exists" do
      let(:name) { :one }

      it { should eq(2) }
    end

    context "when the capture name does not exist" do
      let(:name) { :uh_oh }

      it "raises an error" do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Engine do
  describe "#parse" do
    subject { described_class.new.parse(source) }

    context "with invalid source" do
      let(:source) { "%haml?" }

      it "raises an error" do
        expect { subject }.to raise_error SlimLint::Exceptions::ParseError
      end

      it "includes the line number in the exception" do
        subject
      rescue SlimLint::Exceptions::ParseError => e
        e.lineno.should eq(1)
      end
    end

    context "with valid source" do
      let(:source) { <<~SLIM }
        doctype html
        head
          title My title
      SLIM

      it "parses" do
        subject.match?([:multi, [:html, :doctype]]).should eq(true)
      end

      it "injects line numbers" do
        subject.line.should eq(1)
      end
    end
  end
end

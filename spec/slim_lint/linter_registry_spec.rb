# frozen_string_literal: true

require "spec_helper"

class SlimLint::Linter::SomeLinter < SlimLint::Linter
  include SlimLint::LinterRegistry
end

class SlimLint::Linter::SomeOtherLinter < SlimLint::Linter::SomeLinter; end

describe SlimLint::LinterRegistry do
  context "when including the LinterRegistry module" do
    it "adds the linter to the set of registered linters" do
      klass = Class.new(SlimLint::Linter)
      expect { klass.include SlimLint::LinterRegistry }.to change { SlimLint::LinterRegistry.linters.count }.by(1)
    end
  end

  describe ".extract_linters_from" do
    let(:linters) do
      [SlimLint::Linter::SomeLinter, SlimLint::Linter::SomeOtherLinter]
    end

    context "when the linters exist" do
      let(:linter_names) { %w[SomeLinter SomeOtherLinter] }

      it "returns the linters" do
        subject.extract_linters_from(linter_names).should eq(linters)
      end
    end

    context "when the linters don't exist" do
      let(:linter_names) { ["SomeRandomLinter"] }

      it "raises an error" do
        expect { subject.extract_linters_from(linter_names) }.to raise_error(SlimLint::NoSuchLinter)
      end
    end
  end
end

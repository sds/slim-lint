# frozen_string_literal: true

require "spec_helper"

describe "Config comments" do
  context "single file" do
    include_context "linter"

    let(:described_class) { SlimLint::Linter::TagCase }

    let(:slim) { <<~SLIM }
      IMG src="images/cat.gif"

      / slim-lint:disable TagCase
      IMG src="images/cat.gif"
      / slim-lint:enable TagCase

      IMG src="images/cat.gif"
    SLIM

    it { should report_lint line: 1 }
    it { should_not report_lint line: 4 }
    it { should report_lint line: 7 }
  end

  context "multiple files" do
    # We can't use the 'linter' shared context here because it assumes
    # that the linter is being run on a single file.

    let(:described_class) { SlimLint::Linter::TagCase }

    let(:config) do
      SlimLint::ConfigurationLoader.default_configuration
        .for_linter(described_class)
    end

    subject { described_class.new(config) }

    let(:first_file) { <<~SLIM }
      IMG src="images/cat.gif"
    SLIM

    let(:second_file) { <<~SLIM }
      IMG src="images/cat.gif"

      / slim-lint:disable TagCase
      IMG src="images/cat.gif"
      / slim-lint:enable TagCase

      IMG src="images/cat.gif"
    SLIM

    it "handles the enable/disable config comment properly when reusing the linter" do
      first_document = SlimLint::Document.new(first_file, config: config)
      subject.run(first_document)

      expect(subject).to report_lint line: 1

      second_document = SlimLint::Document.new(second_file, config: config)
      subject.run(second_document)

      expect(subject).to report_lint line: 1
      expect(subject).to_not report_lint line: 4
      expect(subject).to report_lint line: 7
    end
  end
end

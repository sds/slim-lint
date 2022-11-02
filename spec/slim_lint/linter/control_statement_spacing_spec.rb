# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Linter::ControlStatementSpacing do
  include_context "linter"

  context "in the default configuration" do
    context "with space after -" do
      let(:slim) { "- good" }
      it { should_not report_lint }
    end

    context "without space after -" do
      let(:slim) { "-bad" }

      it { should report_lint }
    end

    context "with space after -#" do
      let(:slim) { "-# good" }
      it { should_not report_lint }
    end

    context "without space after -#" do
      let(:slim) { "-#bad" }

      it { should report_lint }
    end
  end

  context "configured to require a single space" do
    let(:config) { {"space_after" => "always"} }

    context "with space after -" do
      let(:slim) { "- good" }
      it { should_not report_lint }
    end

    context "without space after -" do
      let(:slim) { "-bad" }

      it { should report_lint }
    end

    context "with space after -#" do
      let(:slim) { "-# good" }
      it { should_not report_lint }
    end

    context "without space after -#" do
      let(:slim) { "-#bad" }

      it { should report_lint }
    end
  end

  context "configured to require no space" do
    let(:config) { {"space_after" => "never"} }

    context "with space after -" do
      let(:slim) { "- bad" }
      it { should report_lint }
    end

    context "without space after -" do
      let(:slim) { "-good" }
      it { should_not report_lint }
    end

    context "with space after -#" do
      let(:slim) { "-# bad" }
      it { should report_lint }
    end

    context "without space after -#" do
      let(:slim) { "-#good" }
      it { should_not report_lint }
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Linter::TrailingBlankLines do
  include_context "linter"

  context "when line does not have line feed" do
    let(:slim) { ".style\n  .other" }

    it { should report_lint line: 2 }
  end

  context "when last line does not have line feed" do
    let(:slim) { ".style\n  .other" }

    it { should report_lint line: 2 }
  end

  context "when line contains multiple trailing newline" do
    let(:slim) { ".style\n\n" }

    it { should report_lint line: 2 }
  end

  context "when line contains trailing newline" do
    let(:slim) { ".style\n" }

    it { should_not report_lint }
  end

  context "when last line does not have line feed" do
    let(:slim) { ".style\n  .other\n" }

    it { should_not report_lint }
  end

  context "when source is empty" do
    let(:slim) { "" }

    it { should_not report_lint }
  end
end

# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Linter::FileLength do
  include_context "linter"

  context "when a file contains too many lines" do
    let(:slim) { (0..300).to_a.join("\n") }

    it { should report_lint line: 1 }
  end

  context "when a file does not contain too many lines" do
    let(:slim) { (0..299).to_a.join("\n") }

    it { should_not report_lint }
  end
end

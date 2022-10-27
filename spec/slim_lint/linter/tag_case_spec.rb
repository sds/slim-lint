# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Linter::TagCase do
  include_context "linter"

  context "when a tag is all lowercase" do
    let(:slim) { 'img src="images/cat.gif"' }

    it { should_not report_lint }
  end

  context "when a tag contains uppercase characters" do
    let(:slim) { 'IMG src="images/cat.gif"' }

    it { should report_lint line: 1 }
  end
end

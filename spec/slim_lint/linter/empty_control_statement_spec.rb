# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Linter::EmptyControlStatement do
  include_context "linter"

  context "when a control statement contains code" do
    let(:slim) { "- some_code" }

    it { should_not report_lint }
  end

  context "when a control statement contains no code" do
    let(:slim) { "-" }

    it { should report_lint line: 1 }
  end
end

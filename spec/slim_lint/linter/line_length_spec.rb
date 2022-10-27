# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Linter::LineLength do
  include_context "linter"

  context "when a file contains lines which are too long" do
    let(:slim) { <<~SLIM }
      p
        = link_to 'Foobar', this_is_a_really_really_really_really_really_long_method_name
        | This line is short
    SLIM

    it { should_not report_lint line: 1 }
    it { should report_lint line: 2 }
    it { should_not report_lint line: 3 }
  end

  context "when a file does not contain lines which are too long" do
    let(:slim) { <<~SLIM }
      p
        = link_to 'Foobar', a_short_method
        | This line is short
    SLIM

    it { should_not report_lint }
  end
end

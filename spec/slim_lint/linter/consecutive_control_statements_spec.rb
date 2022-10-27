# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Linter::ConsecutiveControlStatements do
  include_context "linter"

  context "when a single control statement exists" do
    let(:slim) { <<~SLIM }
      p Hello world
      - some_code
      a href="link"
    SLIM

    it { should_not report_lint }
  end

  context "when multiple consecutive control statements under the limit exist" do
    let(:slim) { <<~SLIM }
      p Hello world
      - some_code
      - some_more_code
      a href="link"
    SLIM

    it { should_not report_lint }
  end

  context "when multiple consecutive control statements over the limit exist" do
    let(:slim) { <<~SLIM }
      p Hello world
      - some_code
      - some_more_code
      - yet_more_code
      a href="link"
    SLIM

    it { should report_lint line: 2 }
  end

  context "when multiple groups of consecutive control statements over the limit exist" do
    let(:slim) { <<~SLIM }
      p Hello world
      - some_code
      - some_more_code
      - yet_more_code
      a href="link"
      - again_some_code
      - again_some_more_code
      - again_yet_more_code
    SLIM

    it { should report_lint line: 2 }
    it { should report_lint line: 6 }
  end

  context "when a large if/elsif/else statement exists" do
    let(:slim) { <<~SLIM }
      p Hello world
      - if some_condition
        - some_code
      - elsif some_other_condition
        - some_other_code
      - else
        - some_else_code
      a href="link"
    SLIM

    it { should_not report_lint }
  end
end

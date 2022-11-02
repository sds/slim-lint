# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Linter::AvoidMultilineExpressions do
  include_context "linter"

  context "control statements" do
    context "containing a single line of code" do
      let(:slim) { <<-'SLIM' }
        - some_code
      SLIM

      it { should_not report_lint }
    end

    context "containing an escaped newline" do
      let(:slim) { <<-'SLIM' }
        - 1 +\
          1
      SLIM

      it { should report_lint }
    end

    context "containing a multiline method call" do
      let(:slim) { <<-'SLIM' }
        - method(1,
                 2)
      SLIM

      it { should report_lint }
    end
  end

  context "dynamic output statements" do
    context "containing a single line of code" do
      let(:slim) { <<-'SLIM' }
        = some_code
      SLIM

      it { should_not report_lint }
    end

    context "containing an escaped newline" do
      let(:slim) { <<-'SLIM' }
        = 1 +\
          1
      SLIM

      it { should report_lint }
    end

    context "containing a multiline method call" do
      let(:slim) { <<-'SLIM' }
        = method(1,
                 2)
      SLIM

      it { should report_lint }
    end
  end

  context "tag attributes" do
    context "formed from a single expression" do
      let(:slim) { <<-'SLIM' }
        div class=some_code
      SLIM

      it { should_not report_lint }
    end

    context "containing an escaped newline" do
      let(:slim) { <<-'SLIM' }
        div class=[1 +\
                   1]
      SLIM

      it { should report_lint }
    end

    context "containing a multiline method call" do
      let(:slim) { <<-'SLIM' }
        div class=method(1,
                         2)
      SLIM

      it { should report_lint }
    end
  end

  context "tag splats" do
    context "formed from a single expression" do
      let(:slim) { <<-'SLIM' }
        *some_code
      SLIM

      it { should_not report_lint }
    end

    context "containing an escaped newline" do
      let(:slim) { <<-'SLIM' }
        *{ tag: "div", \
           class: "mine" }
      SLIM

      it { should report_lint }
    end

    context "containing a multiline method call" do
      let(:slim) { <<-'SLIM' }
        *method(1,
                2)
      SLIM

      it { should report_lint }
    end
  end

  context "attribute splats" do
    context "formed from a single expression" do
      let(:slim) { <<-'SLIM' }
        div.foo *some_code
      SLIM

      it { should_not report_lint }
    end

    context "containing an escaped newline" do
      let(:slim) { <<-'SLIM' }
        div.foo *{ id: "me", \
                   title: "mine" }
      SLIM

      it { should report_lint }
    end

    context "containing a multiline method call" do
      let(:slim) { <<-'SLIM' }
        div.foo *method(1,
                        2)
      SLIM

      it { should report_lint }
    end
  end
end

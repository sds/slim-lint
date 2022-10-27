# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Linter::RedundantDiv do
  include_context "linter"

  context "when a div tag has no classes or IDs" do
    let(:slim) { <<~SLIM }
      div Hello world
    SLIM

    it { should_not report_lint }
  end

  context "when a div tag has a class attribute" do
    let(:slim) { <<~SLIM }
      div class="class" Hello World
    SLIM

    it { should_not report_lint }
  end

  context "when a div tag has an id attribute" do
    let(:slim) { <<~SLIM }
      div id="identifier" Hello World
    SLIM

    it { should_not report_lint }
  end

  context "when a div tag has a class attribute shortcut" do
    let(:slim) { <<~SLIM }
      div.class Hello world
    SLIM

    it { should report_lint }
  end

  context "when a div has an ID attribute shortcut" do
    let(:slim) { <<~SLIM }
      div#identifier Hello world
    SLIM

    it { should report_lint }
  end

  context "when a nameless tag has a class attribute shortcut" do
    let(:slim) { <<~SLIM }
      .class Hello
    SLIM

    it { should_not report_lint }
  end

  context "when a nameless tag has an ID attribute shortcut" do
    let(:slim) { <<~SLIM }
      #identifier Hello
    SLIM

    it { should_not report_lint }
  end

  context "when a div with a class attribute shortcut is deeply nested" do
    let(:slim) { <<~SLIM }
      tag
        child
          div.class
    SLIM

    it { should report_lint line: 3 }
  end

  context "when an offending div is contained within another offending div" do
    let(:slim) { <<~SLIM }
      div.class
        div.class2
    SLIM

    it { should report_lint line: 1 }
    it { should report_lint line: 2 }
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::Standard do
  include_context "linter"

  context "when RuboCop does not report offences" do
    let(:slim) { <<~SLIM }
      = to_be or not_to_be
    SLIM

    it { should_not report_lint }
  end

  context "when RuboCop reports offences" do
    context "like argument alignment" do
      let(:slim) { <<~SLIM }
        ruby:
          # Good
          method_call(
            1,
            2,
            3
          )

          # Bad
          method_call(
            1,
              2,
            3
          )

          # Okay
          method_call 1,
            2,
            3

          # Bad
          method_call 1,
                      2,
                      3

        / Okay
        - method_call 1,
            2,
            3

        / Okay
        - method_call(1,
            2,
            3)

        / Bad
        = method_call 1,
                      2,
                      3
        / Bad
        = method_call(1,
                      2,
                      3)
      SLIM

      it { should report_lint count: 7 }
      it { should report_lint cop: "Layout/ArgumentAlignment", line: 12 }
      it { should report_lint cop: "Layout/ArgumentAlignment", line: 23 }
      it { should report_lint cop: "Layout/ArgumentAlignment", line: 24 }
      it { should report_lint cop: "Layout/ArgumentAlignment", line: 38 }
      it { should report_lint cop: "Layout/ArgumentAlignment", line: 39 }
      it { should report_lint cop: "Layout/ArgumentAlignment", line: 42 }
      it { should report_lint cop: "Layout/ArgumentAlignment", line: 43 }
    end

    context "like array alignment" do
      let(:slim) { <<~SLIM }
        ruby:
          # Good
          process_array [
            1,
            2,
            3
          ]

          # Okay
          process_array [1, 2, 3,
            4, 5, 6]

          # Bad
          process_array [1, 2, 3,
                         4, 5, 6]

        / Okay
        - process_array [1, 2, 3,
            4, 5, 6]

        / Bad
        - process_array [1, 2, 3,
                         4, 5, 6]
      SLIM

      it { should report_lint count: 2 }
      it { should report_lint cop: "Layout/ArrayAlignment", line: 15 }
      it { should report_lint cop: "Layout/ArrayAlignment", line: 23 }
    end

    context "like block alignment" do
      let(:slim) { <<~SLIM }
        ruby:
          # Good
          process_array do
            "Hooray!"
          end

        / Good
        - process_array do
          = "Hooray!"

        / Good
        - process_array
          = "Hooray!"

        / Good
        = process_array do
          = "Hooray!"

        / Good
        = process_array
          = "Hooray!"
      SLIM

      it { should report_lint count: 0 }
    end

    context "like closing parenthesis indentation" do
      let(:slim) { <<~SLIM }
        ruby:
          # Good
          method_call(
            1
          )

          # Bad
          method_call(
            1
            )
      SLIM

      it { should report_lint count: 1 }
      it { should report_lint cop: "Layout/ClosingParenthesisIndentation", line: 10 }
    end

    context "like end alignment" do
      let(:slim) { <<~SLIM }
        ruby:
          # Good
          _variable = if condition
          end

          # Good
          _variable =
            if condition
            end

          # Bad
          _variable = if condition
              end

        / Good
        - if condition
          = "Great!"
      SLIM

      it { should report_lint count: 1 }
      it { should report_lint cop: "Layout/EndAlignment", line: 13 }
    end

    context "like first argument indentation" do
      let(:slim) { <<~SLIM }
        ruby:
          # Good
          method_call(
            1
          )

          # Bad
          method_call(
          1
          )
      SLIM

      it { should report_lint count: 1 }
      it { should report_lint cop: "Layout/FirstArgumentIndentation", line: 9 }
    end

    context "like first array element indentation" do
      let(:slim) { <<~SLIM }
        ruby:
          # Good
          _array = [
            1
          ]

          # Bad
          _array = [
          1
          ]

          # Bad
          _array = [
              1
          ]
      SLIM

      it { should report_lint count: 2 }
      it { should report_lint cop: "Layout/FirstArrayElementIndentation", line: 9 }
      it { should report_lint cop: "Layout/FirstArrayElementIndentation", line: 14 }
    end

    context "like first hash element indentation" do
      let(:slim) { <<~SLIM }
        ruby:
          # Good
          _hash = {
            foo: 1
          }

          # Bad
          _hash = {
          foo: 1
          }

          # Bad
          _hash = {
              foo: 1
          }
      SLIM

      it { should report_lint count: 2 }
      it { should report_lint cop: "Layout/FirstHashElementIndentation", line: 9 }
      it { should report_lint cop: "Layout/FirstHashElementIndentation", line: 14 }
    end

    context "like hash alignment" do
      let(:slim) { <<~SLIM }
        ruby:
          # Good
          _hash = {
            foo: 1,
            a: 1
          }

          # Bad
          _hash = {
            foo: 1,
              a: 1
          }

          # Bad
          _hash = {
            "foo" => 1,
            "a"   => 1
          }

          # Bad
          _hash = {
            "foo" => 1,
            "a" =>   1
          }
      SLIM

      it { should report_lint count: 3 }
      it { should report_lint cop: "Layout/HashAlignment", line: 11 }
      it { should report_lint cop: "Layout/HashAlignment", line: 17 }
      it { should report_lint cop: "Layout/HashAlignment", line: 23 }
    end

    context "like trailing newlines" do
      let(:slim) { "= no_trailing_newline" }
      it { should_not report_lint }
    end
  end
end

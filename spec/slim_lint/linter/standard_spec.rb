# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Linter::Standard do
  include_context "linter"

  context "when Standard does not report offenses" do
    let(:slim) { <<~'SLIM' }
      = to_be or not_to_be
    SLIM

    it { should_not report_lint }
  end

  context "when Standard reports offenses" do
    context "like argument alignment" do
      let(:slim) { <<~'SLIM' }
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
      let(:slim) { <<~'SLIM' }
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
      let(:slim) { <<~'SLIM' }
        ruby:
          # Good
          process_array do
            "Hooray!"
          end

        / Good
        - process_one do
          = "Hooray!"

        / Good
        - process_two
          = "Hooray!"

        / Good
        = process_three do
          = "Hooray!"

        / Good
        = process_four
          = "Hooray!"
      SLIM

      it { should report_lint count: 0 }
    end

    context "like closing parenthesis indentation" do
      let(:slim) { <<~'SLIM' }
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
      let(:slim) { <<~'SLIM' }
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
      let(:slim) { <<~'SLIM' }
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
      let(:slim) { <<~'SLIM' }
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
      let(:slim) { <<~'SLIM' }
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
      let(:slim) { <<~'SLIM' }
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

  context "reports useful error locations" do
    context "for Layout/AccessModifierIndentation" do
      let(:slim) { <<~'SLIM' }
        ruby:
          @cache << Class.new do
            def public
            end

          private

            def private
            end
          end
      SLIM

      it { should report_lint(cop: "Layout/AccessModifierIndentation", line: 6, columns: 3..10) }
    end

    context "for Layout/ArgumentAlignment" do
      let(:slim) { <<~'SLIM' }
        ruby:
          method(
            :a,
              :b,
            :c
          )

        - method \
            :a,
              :b,
            :c

        = method \
            :a,
              :b,
            :c
      SLIM

      it { should report_lint(cop: "Layout/ArgumentAlignment", line: 4, columns: 7..9) }
      it { should report_lint(cop: "Layout/ArgumentAlignment", line: 10, columns: 7..9) }
      it { should report_lint(cop: "Layout/ArgumentAlignment", line: 15, columns: 7..9) }
    end

    context "for Layout/ArrayAlignment" do
      let(:slim) { <<~'SLIM' }
        ruby:
          @cache << [
            :a,
              :b,
            :c
          ]

          @cache << [:a,
            :b,
              :c,
            :d]

        - @cache << [:a,
              :b,
            :c]

        = @cache << [:a,
              :b,
            :c]
      SLIM

      it { should report_lint(cop: "Layout/ArrayAlignment", line: 4, columns: 7..9) }
      it { should report_lint(cop: "Layout/ArrayAlignment", line: 10, columns: 7..9) }
      it { should report_lint(cop: "Layout/ArrayAlignment", line: 14, columns: 7..9) }
      it { should report_lint(cop: "Layout/ArrayAlignment", line: 18, columns: 7..9) }
    end

    context "for Layout/AssignmentIndentation" do
      let(:slim) { <<~'SLIM' }
        ruby:
          @variable =
          value

          @variable =
                      value
      SLIM

      it { should report_lint(cop: "Layout/AssignmentIndentation", count: 2) }
      it { should report_lint(cop: "Layout/AssignmentIndentation", line: 3, columns: 3..8) }
      it { should report_lint(cop: "Layout/AssignmentIndentation", line: 6, columns: 15..20) }
    end

    context "for Layout/BeginEndAlignment" do
      let(:slim) { <<~'SLIM' }
        ruby:
          @variable = begin
                        do_something
                      end

        - begin
          - do_something
      SLIM

      it { should report_lint(cop: "Layout/BeginEndAlignment", count: 1) }
      it { should report_lint(cop: "Layout/BeginEndAlignment", line: 4, columns: 15..18) }
    end

    context "for Layout/BlockAlignment" do
      # EnforcedStyleAlignWith: either
      let(:slim) { <<~'SLIM' }
        ruby:
          foo
            .call do
          end

          foo
            .call do
            end

          foo
            .call do
               end

        - call do
          div Hooray!
      SLIM

      it { should report_lint(cop: "Layout/BlockAlignment", count: 1) }
      it { should report_lint(cop: "Layout/BlockAlignment", line: 12, columns: 8..11) }
    end

    context "for Layout/BlockEndNewline" do
      let(:slim) { <<~'SLIM' }
        ruby:
          call do
            something end
      SLIM

      it { should report_lint(cop: "Layout/BlockEndNewline", count: 1) }
      it { should report_lint(cop: "Layout/BlockEndNewline", line: 3, columns: 15..18) }
    end

    context "for Layout/CaseIndentation" do
      # EnforcedStyle: end
      let(:slim) { <<~'SLIM' }
        ruby:
          case foo
          when "bar" then 1
            when "baz" then 2
          when "bax" then 3
          end
      SLIM

      it { should report_lint(cop: "Layout/CaseIndentation", count: 1) }
      it { should report_lint(cop: "Layout/CaseIndentation", line: 4, columns: 5..9) }
    end

    context "for Layout/ClosingHeredocIndentation" do
    end

    context "for Layout/ClosingParenthesisIndentation" do
    end

    context "for Layout/CommentIndentation" do
    end

    context "for Layout/ConditionPosition" do
    end

    context "for Layout/DefEndAlignment" do
      # EnforcedStyleAlignWith: start_of_line
      # AutoCorrect: true
      # Severity: warning
    end

    context "for Layout/DotPosition" do
      # EnforcedStyle: leading
    end

    context "for Layout/ElseAlignment" do
      let(:slim) { <<~'SLIM' }
        ruby:
          case foo
          when "bar" then 1
            else 3
          end

          if foo
            do_something
            else do_something_else
          end

          unless foo
            do_something
            else do_something_else
          end
      SLIM

      it { should report_lint(cop: "Layout/ElseAlignment", count: 3) }
      it { should report_lint(cop: "Layout/ElseAlignment", line: 4, columns: 5..9) }
      it { should report_lint(cop: "Layout/ElseAlignment", line: 9, columns: 5..9) }
      it { should report_lint(cop: "Layout/ElseAlignment", line: 14, columns: 5..9) }
    end

    context "for Layout/EmptyComment" do
      # AllowBorderComment: true
      # AllowMarginComment: true
    end

    context "for Layout/EmptyLineAfterMagicComment" do
    end

    context "for Layout/EmptyLineBetweenDefs" do
      # AllowAdjacentOneLineDefs: false
      # NumberOfEmptyLines: 1
    end

    context "for Layout/EmptyLines" do
    end

    context "for Layout/EmptyLinesAroundAccessModifier" do
    end

    context "for Layout/EmptyLinesAroundArguments" do
    end

    context "for Layout/EmptyLinesAroundBeginBody" do
    end

    context "for Layout/EmptyLinesAroundBlockBody" do
      # EnforcedStyle: no_empty_lines
    end

    context "for Layout/EmptyLinesAroundClassBody" do
      # EnforcedStyle: no_empty_lines
    end

    context "for Layout/EmptyLinesAroundExceptionHandlingKeywords" do
    end

    context "for Layout/EmptyLinesAroundMethodBody" do
    end

    context "for Layout/EmptyLinesAroundModuleBody" do
      # EnforcedStyle: no_empty_lines
    end

    context "for Layout/EndAlignment" do
      # AutoCorrect: true
      # EnforcedStyleAlignWith: variable
      # Severity: warning
    end

    context "for Layout/EndOfLine" do
      # EnforcedStyle: native
    end

    context "for Layout/ExtraSpacing" do
      # AllowForAlignment: false
      # AllowBeforeTrailingComments: false
      # ForceEqualSignAlignment: false
    end

    context "for Layout/FirstArgumentIndentation" do
      # EnforcedStyle: consistent
      # IndentationWidth: ~
    end

    context "for Layout/FirstArrayElementIndentation" do
      # EnforcedStyle: consistent
      # IndentationWidth: ~
    end

    context "for Layout/FirstHashElementIndentation" do
      # EnforcedStyle: consistent
      # IndentationWidth: ~
    end

    context "for Layout/HashAlignment" do
      # EnforcedHashRocketStyle: key
      # EnforcedColonStyle: key
      # EnforcedLastArgumentHashStyle: always_inspect
    end

    context "for Layout/HeredocIndentation" do
    end

    context "for Layout/IndentationConsistency" do
      # EnforcedStyle: normal
    end

    context "for Layout/IndentationStyle" do
      # IndentationWidth: ~
    end

    context "for Layout/IndentationWidth" do
      # Width: 2
      # AllowedPatterns: []
    end

    context "for Layout/InitialIndentation" do
    end

    context "for Layout/LeadingCommentSpace" do
    end

    context "for Layout/LeadingEmptyLines" do
    end

    context "for Layout/LineContinuationSpacing" do
    end

    context "for Layout/MultilineArrayBraceLayout" do
      # EnforcedStyle: symmetrical
    end

    context "for Layout/MultilineBlockLayout" do
    end

    context "for Layout/MultilineHashBraceLayout" do
      # EnforcedStyle: symmetrical
    end

    context "for Layout/MultilineMethodCallBraceLayout" do
      # EnforcedStyle: symmetrical
    end

    context "for Layout/MultilineMethodCallIndentation" do
      # EnforcedStyle: indented
      # IndentationWidth: ~
    end

    context "for Layout/MultilineMethodDefinitionBraceLayout" do
      # EnforcedStyle: symmetrical
    end

    context "for Layout/MultilineOperationIndentation" do
      # EnforcedStyle: indented
      # IndentationWidth: ~
    end

    context "for Layout/ParameterAlignment" do
      # EnforcedStyle: with_fixed_indentation
      # IndentationWidth: ~
    end

    context "for Layout/RescueEnsureAlignment" do
      let(:slim) { <<~'SLIM' }
        ruby:
          begin
            do_something
            rescue
            something_else
          end
      SLIM

      it { should report_lint(cop: "Layout/RescueEnsureAlignment", count: 1) }
      it { should report_lint(cop: "Layout/RescueEnsureAlignment", line: 4, columns: 5..11) }
    end

    context "for Layout/SpaceAfterColon" do
      let(:slim) { <<~'SLIM' }
        ruby:
          call(a:1)
          call({a:1})

        - call(a:1)
        - call({a:1})

        = call(a:1)
        = call({a:1})

        tag This is a #{call(a:1)}
        tag This is a #{call({a:1})}

        ' This is a #{call(a:1)}
        ' This is a #{call({a:1})}
      SLIM

      it { should report_lint(cop: "Layout/SpaceAfterColon", line: 2, columns: 9..10) }
      it { should report_lint(cop: "Layout/SpaceAfterColon", line: 3, columns: 10..11) }
      it { should report_lint(cop: "Layout/SpaceAfterColon", line: 5, columns: 9..10) }
      it { should report_lint(cop: "Layout/SpaceAfterColon", line: 6, columns: 10..11) }
      it { should report_lint(cop: "Layout/SpaceAfterColon", line: 8, columns: 9..10) }
      it { should report_lint(cop: "Layout/SpaceAfterColon", line: 9, columns: 10..11) }
      it { should report_lint(cop: "Layout/SpaceAfterColon", line: 11, columns: 23..24) }
      it { should report_lint(cop: "Layout/SpaceAfterColon", line: 12, columns: 24..25) }
      it { should report_lint(cop: "Layout/SpaceAfterColon", line: 14, columns: 21..22) }
      it { should report_lint(cop: "Layout/SpaceAfterColon", line: 15, columns: 22..23) }
    end

    context "for Layout/SpaceAfterComma" do
      let(:slim) { <<~'SLIM' }
        ruby:
          call(1,2)
          call(a: 1,b: 2)
          call({a: 1,b: 2})
          call([1,2])
          call([a: 1,b: 2])

        - call(1,2)
        - call(a: 1,b: 2)
        - call({a: 1,b: 2})
        - call([1,2])
        - call([a: 1,b: 2])

        = call(1,2)
        = call(a: 1,b: 2)
        = call({a: 1,b: 2})
        = call([1,2])
        = call([a: 1,b: 2])

        tag Interpolated #{call(1,2)}
        tag Interpolated #{call(a: 1,b: 2)}
        tag Interpolated #{call({a: 1,b: 2})}
        tag Interpolated #{call([1,2])}
        tag Interpolated #{call([a: 1,b: 2])}

        ' Interpolated #{call(1,2)}
        ' Interpolated #{call(a: 1,b: 2)}
        ' Interpolated #{call({a: 1,b: 2})}
        ' Interpolated #{call([1,2])}
        ' Interpolated #{call([a: 1,b: 2])}
      SLIM

      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 2, columns: 9..10) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 3, columns: 12..13) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 4, columns: 13..14) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 5, columns: 10..11) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 6, columns: 13..14) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 8, columns: 9..10) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 9, columns: 12..13) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 10, columns: 13..14) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 11, columns: 10..11) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 12, columns: 13..14) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 14, columns: 9..10) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 15, columns: 12..13) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 16, columns: 13..14) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 17, columns: 10..11) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 18, columns: 13..14) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 20, columns: 26..27) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 21, columns: 29..30) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 22, columns: 30..31) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 23, columns: 27..28) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 24, columns: 30..31) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 26, columns: 24..25) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 27, columns: 27..28) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 28, columns: 28..29) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 29, columns: 25..26) }
      it { should report_lint(cop: "Layout/SpaceAfterComma", line: 30, columns: 28..29) }
    end

    context "for Layout/SpaceAfterMethodName" do
    end

    context "for Layout/SpaceAfterNot" do
    end

    context "for Layout/SpaceAfterSemicolon" do
    end

    context "for Layout/SpaceAroundBlockParameters" do
      # EnforcedStyleInsidePipes: no_space
    end

    context "for Layout/SpaceAroundEqualsInParameterDefault" do
      # EnforcedStyle: space
    end

    context "for Layout/SpaceAroundKeyword" do
    end

    context "for Layout/SpaceAroundMethodCallOperator" do
    end

    context "for Layout/SpaceAroundOperators" do
      # AllowForAlignment: true
    end

    context "for Layout/SpaceBeforeBlockBraces" do
      # EnforcedStyle: space
      # EnforcedStyleForEmptyBraces: space
    end

    context "for Layout/SpaceBeforeComma" do
    end

    context "for Layout/SpaceBeforeComment" do
    end

    context "for Layout/SpaceBeforeFirstArg" do
      # AllowForAlignment: true
    end

    context "for Layout/SpaceBeforeSemicolon" do
    end

    context "for Layout/SpaceInLambdaLiteral" do
      # EnforcedStyle: require_no_space
    end

    context "for Layout/SpaceInsideArrayLiteralBrackets" do
      # EnforcedStyle: no_space
      # EnforcedStyleForEmptyBrackets: no_space
    end

    context "for Layout/SpaceInsideArrayPercentLiteral" do
    end

    context "for Layout/SpaceInsideBlockBraces" do
      # EnforcedStyle: space
      # EnforcedStyleForEmptyBraces: no_space
      # SpaceBeforeBlockParameters: true
    end

    context "for Layout/SpaceInsideHashLiteralBraces" do
      # EnforcedStyle: no_space
      # EnforcedStyleForEmptyBraces: no_space
    end

    context "for Layout/SpaceInsideParens" do
      # EnforcedStyle: no_space
    end

    context "for Layout/SpaceInsidePercentLiteralDelimiters" do
    end

    context "for Layout/SpaceInsideRangeLiteral" do
    end

    context "for Layout/SpaceInsideReferenceBrackets" do
      # EnforcedStyle: no_space
      # EnforcedStyleForEmptyBrackets: no_space
    end

    context "for Layout/SpaceInsideStringInterpolation" do
      let(:slim) { <<~'SLIM' }
        ruby:
          echo "This uses #{ spaces } inside an interpolation."

        - echo "This uses #{ spaces } inside an interpolation."
        = echo "This uses #{ spaces } inside an interpolation."

        span This uses #{ spaces } inside an implicit interpolation.
        ' This uses #{ spaces } inside an implicit interpolation.
        | This uses #{ spaces } inside an implicit interpolation.

        | This is a multiline #{ interpolation } that
          has multiple #{ offenses } nested within it
          and we expect to #{ catch } all of them.
      SLIM

      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 2, columns: 21..22) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 2, columns: 28..29) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 4, columns: 21..22) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 4, columns: 28..29) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 5, columns: 21..22) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 5, columns: 28..29) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 7, columns: 18..19) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 7, columns: 25..26) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 8, columns: 15..16) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 8, columns: 22..23) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 9, columns: 15..16) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 9, columns: 22..23) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 11, columns: 25..26) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 11, columns: 39..40) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 12, columns: 18..19) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 12, columns: 27..28) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 13, columns: 22..23) }
      it { should report_lint(cop: "Layout/SpaceInsideStringInterpolation", line: 13, columns: 28..29) }
    end

    context "for Layout/TrailingEmptyLines" do
      # EnforcedStyle: final_newline
    end

    context "for Layout/TrailingWhitespace" do
      # AllowInHeredoc: true
    end

    context "for Lint/AmbiguousAssignment" do
    end

    context "for Lint/AmbiguousOperator" do
    end

    context "for Lint/AmbiguousRegexpLiteral" do
    end

    context "for Lint/AssignmentInCondition" do
      # AllowSafeAssignment: true
    end

    context "for Lint/BigDecimalNew" do
    end

    context "for Lint/BinaryOperatorWithIdenticalOperands" do
    end

    context "for Lint/BooleanSymbol" do
    end

    context "for Lint/CircularArgumentReference" do
    end

    context "for Lint/ConstantDefinitionInBlock" do
    end

    context "for Lint/ConstantOverwrittenInRescue" do
    end

    context "for Lint/Debugger" do
    end

    context "for Lint/DeprecatedClassMethods" do
    end

    context "for Lint/DeprecatedConstants" do
    end

    context "for Lint/DeprecatedOpenSSLConstant" do
    end

    context "for Lint/DuplicateCaseCondition" do
    end

    context "for Lint/DuplicateElsifCondition" do
    end

    context "for Lint/DuplicateHashKey" do
    end

    context "for Lint/DuplicateMethods" do
    end

    context "for Lint/DuplicateRegexpCharacterClassElement" do
    end

    context "for Lint/DuplicateRequire" do
    end

    context "for Lint/DuplicateRescueException" do
    end

    context "for Lint/EachWithObjectArgument" do
    end

    context "for Lint/ElseLayout" do
    end

    context "for Lint/EmptyEnsure" do
      # AutoCorrect: true
    end

    context "for Lint/EmptyExpression" do
    end

    context "for Lint/EmptyInterpolation" do
    end

    context "for Lint/EmptyWhen" do
      # AllowComments: true
    end

    context "for Lint/EnsureReturn" do
    end

    context "for Lint/ErbNewArguments" do
    end

    context "for Lint/FlipFlop" do
    end

    context "for Lint/FloatComparison" do
    end

    context "for Lint/FloatOutOfRange" do
    end

    context "for Lint/FormatParameterMismatch" do
    end

    context "for Lint/IdentityComparison" do
    end

    context "for Lint/ImplicitStringConcatenation" do
    end

    context "for Lint/IneffectiveAccessModifier" do
    end

    context "for Lint/InheritException" do
      # EnforcedStyle: runtime_error
    end

    context "for Lint/InterpolationCheck" do
    end

    context "for Lint/LiteralAsCondition" do
    end

    context "for Lint/LiteralInInterpolation" do
    end

    context "for Lint/Loop" do
    end

    context "for Lint/MissingCopEnableDirective" do
      # MaximumRangeSize: .inf
    end

    context "for Lint/MixedRegexpCaptureTypes" do
    end

    context "for Lint/MultipleComparison" do
    end

    context "for Lint/NestedMethodDefinition" do
    end

    context "for Lint/NestedPercentLiteral" do
    end

    context "for Lint/NextWithoutAccumulator" do
    end

    context "for Lint/NonDeterministicRequireOrder" do
    end

    context "for Lint/NonLocalExitFromIterator" do
    end

    context "for Lint/NumberedParameterAssignment" do
    end

    context "for Lint/OrAssignmentToConstant" do
    end

    context "for Lint/OrderedMagicComments" do
    end

    context "for Lint/OutOfRangeRegexpRef" do
    end

    context "for Lint/ParenthesesAsGroupedExpression" do
    end

    context "for Lint/PercentSymbolArray" do
    end

    context "for Lint/RaiseException" do
    end

    context "for Lint/RandOne" do
    end

    context "for Lint/RedundantRequireStatement" do
    end

    context "for Lint/RedundantSplatExpansion" do
    end

    context "for Lint/RedundantStringCoercion" do
    end

    context "for Lint/RedundantWithIndex" do
    end

    context "for Lint/RedundantWithObject" do
    end

    context "for Lint/RefinementImportMethods" do
      # SafeAutoCorrect: false
    end

    context "for Lint/RegexpAsCondition" do
    end

    context "for Lint/RequireParentheses" do
    end

    context "for Lint/RequireRangeParentheses" do
    end

    context "for Lint/RequireRelativeSelfPath" do
    end

    context "for Lint/RescueException" do
    end

    context "for Lint/RescueType" do
    end

    context "for Lint/ReturnInVoidContext" do
    end

    context "for Lint/SafeNavigationChain" do
      # AllowedMethods:
      #   - present?
      #   - blank?
      #   - presence
      #   - try
      #   - try!
    end

    context "for Lint/SafeNavigationConsistency" do
      # AllowedMethods:
      #   - present?
      #   - blank?
      #   - presence
      #   - try
      #   - try!
    end

    context "for Lint/SafeNavigationWithEmpty" do
    end

    context "for Lint/SelfAssignment" do
    end

    context "for Lint/ShadowedArgument" do
      # IgnoreImplicitReferences: false
    end

    context "for Lint/ShadowedException" do
    end

    context "for Lint/SymbolConversion" do
    end

    context "for Lint/Syntax" do
    end

    context "for Lint/TopLevelReturnWithArgument" do
    end

    context "for Lint/TrailingCommaInAttributeDeclaration" do
    end

    context "for Lint/TripleQuotes" do
    end

    context "for Lint/UnderscorePrefixedVariableName" do
    end

    context "for Lint/UnifiedInteger" do
    end

    context "for Lint/UnreachableCode" do
    end

    context "for Lint/UriEscapeUnescape" do
    end

    context "for Lint/UriRegexp" do
    end

    context "for Lint/UselessAssignment" do
    end

    context "for Lint/UselessRuby2Keywords" do
    end

    context "for Lint/UselessSetterCall" do
    end

    context "for Lint/UselessTimes" do
    end

    context "for Lint/Void" do
      # CheckForMethodsWithNoSideEffects: false
      let(:slim) { <<~'SLIM' }
        ruby:
          "void string"
          :void_symbol
          not_a_void_method

        - "void control string"
        - "multiline \
          void control string"
        - not_a_void_control_method

        = "not a void string"
        = "not a multiline \
          void string"
        = not_a_void_method

        div = "not a void string"
        div = not_a_void_method

        div attr="not a void string"
        div attr=["not a void array"]

        div.end
      SLIM

      it { should report_lint(cop: "Lint/Void", count: 4) }
      it { should report_lint(cop: "Lint/Void", line: 2, columns: 3..16) }
      it { should report_lint(cop: "Lint/Void", line: 3, columns: 3..15) }
      it { should report_lint(cop: "Lint/Void", line: 6, columns: 3..24) }
      it { should report_lint(cop: "Lint/Void", line: 7, columns: 3..23) }
    end

    context "for Migration/DepartmentName" do
    end

    context "for Naming/BinaryOperatorParameterName" do
    end

    context "for Naming/BlockParameterName" do
      # MinNameLength: 1
      # AllowNamesEndingInNumbers: true
      # AllowedNames: []
      # ForbiddenNames: []
    end

    context "for Naming/ClassAndModuleCamelCase" do
    end

    context "for Naming/ConstantName" do
    end

    context "for Naming/HeredocDelimiterCase" do
      # EnforcedStyle: uppercase
    end

    context "for Naming/VariableName" do
      # EnforcedStyle: snake_case
    end

    context "for Performance/BigDecimalWithNumericArgument" do
    end

    context "for Performance/BindCall" do
    end

    context "for Performance/BlockGivenWithExplicitBlock" do
    end

    context "for Performance/Caller" do
    end

    context "for Performance/CompareWithBlock" do
    end

    context "for Performance/ConcurrentMonotonicTime" do
    end

    context "for Performance/ConstantRegexp" do
    end

    context "for Performance/Count" do
    end

    context "for Performance/Detect" do
    end

    context "for Performance/DoubleStartEndWith" do
      # IncludeActiveSupportAliases: false
    end

    context "for Performance/EndWith" do
    end

    context "for Performance/FixedSize" do
    end

    context "for Performance/FlatMap" do
      # EnabledForFlattenWithoutParams: false
    end

    context "for Performance/InefficientHashSearch" do
      # Safe: false
    end

    context "for Performance/RangeInclude" do
      # Safe: false
    end

    context "for Performance/RedundantMatch" do
    end

    context "for Performance/RedundantMerge" do
      # MaxKeyValuePairs: 2
    end

    context "for Performance/RedundantSortBlock" do
    end

    context "for Performance/RedundantSplitRegexpArgument" do
    end

    context "for Performance/RedundantStringChars" do
    end

    context "for Performance/RegexpMatch" do
    end

    context "for Performance/ReverseEach" do
    end

    context "for Performance/ReverseFirst" do
    end

    context "for Performance/Size" do
    end

    context "for Performance/SortReverse" do
    end

    context "for Performance/Squeeze" do
    end

    context "for Performance/StartWith" do
    end

    context "for Performance/StringIdentifierArgument" do
    end

    context "for Performance/StringReplacement" do
    end

    context "for Performance/UnfreezeString" do
    end

    context "for Performance/UriDefaultParser" do
    end

    context "for Security/CompoundHash" do
    end

    context "for Security/Eval" do
      # Safe: false
    end

    context "for Security/JSONLoad" do
      # AutoCorrect: false
      # SafeAutoCorrect: false
    end

    context "for Security/Open" do
      # Safe: false
    end

    context "for Security/YAMLLoad" do
      # SafeAutoCorrect: false
    end

    context "for BlockSingleLineBraces" do
    end

    context "for Style/Alias" do
      # EnforcedStyle: prefer_alias_method
    end

    context "for Style/AndOr" do
    end

    context "for Style/ArgumentsForwarding" do
      # AllowOnlyRestArgument: true
    end

    context "for Style/ArrayJoin" do
    end

    context "for Style/Attr" do
    end

    context "for Style/BarePercentLiterals" do
      # EnforcedStyle: bare_percent
    end

    context "for Style/BeginBlock" do
    end

    context "for Style/BlockComments" do
    end

    context "for Style/CharacterLiteral" do
    end

    context "for Style/ClassCheck" do
      # EnforcedStyle: is_a?
    end

    context "for Style/ClassEqualityComparison" do
    end

    context "for Style/ClassMethods" do
    end

    context "for Style/ColonMethodCall" do
    end

    context "for Style/ColonMethodDefinition" do
    end

    context "for Style/CommandLiteral" do
      # EnforcedStyle: mixed
      # AllowInnerBackticks: false
    end

    context "for Style/ConditionalAssignment" do
      # EnforcedStyle: assign_to_condition
      # SingleLineConditionsOnly: true
      # IncludeTernaryExpressions: true
    end

    context "for Style/DefWithParentheses" do
    end

    context "for Style/Dir" do
    end

    context "for Style/EachForSimpleLoop" do
    end

    context "for Style/EachWithObject" do
    end

    context "for Style/EmptyBlockParameter" do
    end

    context "for Style/EmptyCaseCondition" do
    end

    context "for Style/EmptyElse" do
      # EnforcedStyle: both
    end

    context "for Style/EmptyLambdaParameter" do
    end

    context "for Style/EmptyLiteral" do
    end

    context "for Style/EmptyMethod" do
      # EnforcedStyle: expanded
    end

    context "for Style/Encoding" do
    end

    context "for Style/EndBlock" do
      # AutoCorrect: true
    end

    context "for Style/EvalWithLocation" do
    end

    context "for Style/FileRead" do
    end

    context "for Style/FileWrite" do
    end

    context "for Style/For" do
      # EnforcedStyle: each
    end

    context "for Style/GlobalStdStream" do
    end

    context "for Style/GlobalVars" do
      # AllowedVariables: []
    end

    context "for Style/HashConversion" do
    end

    context "for Style/HashExcept" do
    end

    context "for Style/HashSyntax" do
      # EnforcedStyle: ruby19_no_mixed_keys
      # EnforcedShorthandSyntax: either
    end

    context "for Style/IdenticalConditionalBranches" do
    end

    context "for Style/IfInsideElse" do
    end

    context "for Style/IfUnlessModifierOfIfUnless" do
    end

    context "for Style/IfWithBooleanLiteralBranches" do
    end

    context "for Style/IfWithSemicolon" do
    end

    context "for Style/InfiniteLoop" do
    end

    context "for Style/KeywordParametersOrder" do
    end

    context "for Style/LambdaCall" do
      # EnforcedStyle: call
    end

    context "for Style/LineEndConcatenation" do
      # SafeAutoCorrect: false
    end

    context "for Style/MapCompactWithConditionalBlock" do
    end

    context "for Style/MethodCallWithoutArgsParentheses" do
      # AllowedMethods: []
    end

    context "for Style/MissingRespondToMissing" do
    end

    context "for Style/MixinGrouping" do
      # EnforcedStyle: separated
    end

    context "for Style/MixinUsage" do
    end

    context "for Style/MultilineIfModifier" do
    end

    context "for Style/MultilineIfThen" do
    end

    context "for Style/MultilineMemoization" do
      # EnforcedStyle: keyword
    end

    context "for Style/MultilineWhenThen" do
    end

    context "for Style/NegatedWhile" do
    end

    context "for Style/NestedFileDirname" do
    end

    context "for Style/NestedModifier" do
    end

    context "for Style/NestedParenthesizedCalls" do
      # AllowedMethods:
      #   - be
      #   - be_a
      #   - be_an
      #   - be_between
      #   - be_falsey
      #   - be_kind_of
      #   - be_instance_of
      #   - be_truthy
      #   - be_within
      #   - eq
      #   - eql
      #   - end_with
      #   - include
      #   - match
      #   - raise_error
      #   - respond_to
      #   - start_with
    end

    context "for Style/NestedTernaryOperator" do
    end

    context "for Style/NilComparison" do
      # EnforcedStyle: predicate
    end

    context "for Style/NilLambda" do
    end

    context "for Style/NonNilCheck" do
      # IncludeSemanticChanges: false
    end

    context "for Style/Not" do
    end

    context "for Style/NumericLiteralPrefix" do
      # EnforcedOctalStyle: zero_with_o
    end

    context "for Style/OneLineConditional" do
    end

    context "for Style/OptionalArguments" do
    end

    context "for Style/OrAssignment" do
    end

    context "for Style/ParenthesesAroundCondition" do
      # AllowSafeAssignment: true
      # AllowInMultilineConditions: false
    end

    context "for Style/PercentLiteralDelimiters" do
      # PreferredDelimiters:
      #   default: ()
      #   '%i': '[]'
      #   '%I': '[]'
      #   '%r': '{}'
      #   '%w': '[]'
      #   '%W': '[]'
    end

    context "for Style/Proc" do
    end

    context "for Style/QuotedSymbols" do
      # EnforcedStyle: same_as_string_literals
    end

    context "for Style/RandomWithOffset" do
    end

    context "for Style/RedundantAssignment" do
    end

    context "for Style/RedundantBegin" do
    end

    context "for Style/RedundantCondition" do
    end

    context "for Style/RedundantConditional" do
    end

    context "for Style/RedundantException" do
    end

    context "for Style/RedundantFetchBlock" do
    end

    context "for Style/RedundantFileExtensionInRequire" do
    end

    context "for Style/RedundantFreeze" do
    end

    context "for Style/RedundantInitialize" do
    end

    context "for Style/RedundantInterpolation" do
    end

    context "for Style/RedundantParentheses" do
    end

    context "for Style/RedundantPercentQ" do
    end

    context "for Style/RedundantRegexpCharacterClass" do
    end

    context "for Style/RedundantRegexpEscape" do
    end

    context "for Style/RedundantReturn" do
      # AllowMultipleReturnValues: false
    end

    context "for Style/RedundantSelf" do
    end

    context "for Style/RedundantSort" do
    end

    context "for Style/RedundantSortBy" do
    end

    context "for Style/RescueModifier" do
    end

    context "for Style/RescueStandardError" do
      # EnforcedStyle: implicit
    end

    context "for Style/SafeNavigation" do
      # ConvertCodeThatCanStartToReturnNil: false
      # AllowedMethods:
      #   - present?
      #   - blank?
      #   - presence
      #   - try
      #   - try!
    end

    context "for Style/Sample" do
    end

    context "for Style/SelfAssignment" do
    end

    context "for Style/Semicolon" do
      # AllowAsExpressionSeparator: false
    end

    context "for Style/SingleLineMethods" do
      # AllowIfMethodIsEmpty: false
    end

    context "for Style/SlicingWithRange" do
    end

    context "for Style/StabbyLambdaParentheses" do
      # EnforcedStyle: require_parentheses
    end

    context "for Style/StderrPuts" do
    end

    context "for Style/StringChars" do
    end

    context "for Style/StringLiterals" do
      # EnforcedStyle: double_quotes
      # ConsistentQuotesInMultiline: false
    end

    context "for Style/StringLiteralsInInterpolation" do
      # EnforcedStyle: double_quotes
      let(:slim) { <<~'SLIM' }
        ruby:
          p "This #{t('text')} contains an interpolation"
          p "This #{t('text')} #{t('contains')} multiple #{t('translations')}."

        - p "This #{t('text')} contains an interpolation"
        - p "This #{t('text')} #{t('contains')} multiple #{t('translations')}."

        = p "This #{t('text')} contains an interpolation"
        = p "This #{t('text')} #{t('contains')} multiple #{t('translations')}."

        span This #{t('text')} contains an interpolation
        span This #{t('text')} #{t('contains')} multiple #{t('translations')}.
        span This #{t('text')} #{t('contains')}
             multiple #{t('interpolated')} #{t('translations')}.

        span This #{{t('text')}} contains an interpolation
        span This #{{t('text')}} #{{t('contains')}} multiple #{{t('translations')}}.
        span This #{{t('text')}} #{{t('contains')}}
             multiple #{{t('interpolated')}} #{{t('translations')}}.
      SLIM

      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 2, columns: 15..21) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 3, columns: 15..21) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 3, columns: 28..38) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 3, columns: 54..68) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 5, columns: 15..21) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 6, columns: 15..21) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 6, columns: 28..38) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 6, columns: 54..68) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 8, columns: 15..21) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 9, columns: 15..21) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 9, columns: 28..38) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 9, columns: 54..68) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 11, columns: 15..21) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 12, columns: 15..21) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 12, columns: 28..38) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 12, columns: 54..68) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 13, columns: 15..21) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 13, columns: 28..38) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 14, columns: 19..33) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 14, columns: 40..54) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 16, columns: 16..22) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 17, columns: 16..22) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 17, columns: 31..41) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 17, columns: 59..73) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 18, columns: 16..22) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 18, columns: 31..41) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 19, columns: 20..34) }
      it { should report_lint(cop: "Style/StringLiteralsInInterpolation", line: 19, columns: 43..57) }
    end

    context "for Style/Strip" do
    end

    context "for Style/SymbolLiteral" do
    end

    context "for Style/TernaryParentheses" do
      # EnforcedStyle: require_parentheses_when_complex
      # AllowSafeAssignment: true
    end

    context "for Style/TrailingBodyOnClass" do
    end

    context "for Style/TrailingBodyOnMethodDefinition" do
    end

    context "for Style/TrailingBodyOnModule" do
    end

    context "for Style/TrailingCommaInArguments" do
      # EnforcedStyleForMultiline: no_comma
    end

    context "for Style/TrailingCommaInArrayLiteral" do
      # EnforcedStyleForMultiline: no_comma
    end

    context "for Style/TrailingCommaInBlockArgs" do
    end

    context "for Style/TrailingCommaInHashLiteral" do
      # EnforcedStyleForMultiline: no_comma
    end

    context "for Style/TrailingMethodEndStatement" do
    end

    context "for Style/TrivialAccessors" do
      # ExactNameMatch: true
      # AllowPredicates: true
      # AllowDSLWriters: false
      # IgnoreClassMethods: true
      # AllowedMethods:
      #   - to_ary
      #   - to_a
      #   - to_c
      #   - to_enum
      #   - to_h
      #   - to_hash
      #   - to_i
      #   - to_int
      #   - to_io
      #   - to_open
      #   - to_path
      #   - to_proc
      #   - to_r
      #   - to_regexp
      #   - to_str
      #   - to_s
      #   - to_sym
    end

    context "for Style/UnlessElse" do
    end

    context "for Style/UnpackFirst" do
    end

    context "for Style/VariableInterpolation" do
    end

    context "for Style/WhenThen" do
    end

    context "for Style/WhileUntilDo" do
    end

    context "for Style/YodaCondition" do
      # EnforcedStyle: forbid_for_all_comparison_operators
    end
  end
end

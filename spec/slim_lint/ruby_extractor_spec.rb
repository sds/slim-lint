# frozen_string_literal: true

require "spec_helper"

describe SlimLint::RubyExtractor do
  let(:extractor) { described_class.new }

  describe "#extract" do
    let(:sexp) { SlimLint::RubyExtractEngine.new.call(slim) }
    subject { extractor.extract(sexp) }

    context "with an empty Slim document" do
      let(:slim) { "" }
      its(:source) { should eq("\n") }
      its(:source_map) { should eq({}) }
    end

    context "with verbatim text" do
      let(:slim) { <<~'SLIM' }
        | Hello world
      SLIM

      its(:source) { should eq("_slim_lint_puts_0\n") }
      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 3, last_line: 1, last_column: 14}
        })
      end
    end

    context "with verbatim text on multiple lines" do
      let(:slim) { <<~'SLIM' }
        |
          Hello
          world
      SLIM

      its(:source) { should eq("_slim_lint_puts_0\n") }
      its(:source_map) do
        should contain_locations({
          1 => {line: 2, column: 3, last_line: 3, last_column: 8}
        })
      end
    end

    context "with verbatim text with trailing whitespace" do
      let(:slim) { <<~'SLIM' }
        ' Hello world
      SLIM

      its(:source) { should eq("_slim_lint_puts_0\n") }
      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 3, last_line: 1, last_column: 14}
        })
      end
    end

    context "with inline static HTML" do
      let(:slim) { <<~'SLIM' }
        <p><b>Hello world!</b></p>
      SLIM

      its(:source) { should eq("_slim_lint_puts_0\n") }
      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 1, last_line: 1, last_column: 27}
        })
      end
    end

    context "with control code" do
      let(:slim) { <<~'SLIM' }
        - some_expression
      SLIM

      its(:source) { should eq("some_expression\n") }
      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 3, last_line: 1, last_column: 18}
        })
      end
    end

    context "with output code" do
      let(:slim) { <<~'SLIM' }
        = some_expression
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        output do
          some_expression
        end
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 1, last_line: 1, last_column: 3},
          2 => {line: 1, column: 3 - 2, last_line: 1, last_column: 18 - 2},
          3 => {line: 1, column: 1, last_line: 1, last_column: 3}
        })
      end
    end

    context "with a block of ruby code" do
      let(:slim) { <<~'SLIM' }
        ruby:
          if user.admin?
            content_for(:navigation, "ADMIN")
          end
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        if user.admin?
          content_for(:navigation, "ADMIN")
        end
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 2, column: 3, last_line: 2, last_column: 17},
          2 => {line: 3, column: 3, last_line: 3, last_column: 38},
          3 => {line: 4, column: 3, last_line: 4, last_column: 6}
        })
      end
    end

    context "with output code with block contents" do
      let(:slim) { <<~'SLIM' }
        = simple_form_for User.new, url: some_url do |f|
          = f.input :email, autofocus: true
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        output do
          simple_form_for User.new, url: some_url do |f|
            output do
              f.input :email, autofocus: true
            end
          end
        end
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 1, last_line: 1, last_column: 3},
          2 => {line: 1, column: 3 - 2, last_line: 1, last_column: 49 - 2},
          3 => {line: 2, column: 3 - 4, last_line: 2, last_column: 3 - 2},
          4 => {line: 2, column: 5 - 6, last_line: 2, last_column: 36 - 6},
          5 => {line: 2, column: 3 - 4, last_line: 2, last_column: 3 - 2},
          6 => {line: 1, column: 3 - 2, last_line: 1, last_column: 1},
          7 => {line: 1, column: 1, last_line: 1, last_column: 3}
        })
      end
    end

    context "with output without escaping" do
      let(:slim) { <<~'SLIM' }
        == some_expression
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        output do
          some_expression
        end
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 1, last_line: 1, last_column: 4},
          2 => {line: 1, column: 4 - 2, last_line: 1, last_column: 19 - 2},
          3 => {line: 1, column: 1, last_line: 1, last_column: 4}
        })
      end
    end

    context "with a code comment" do
      let(:slim) { <<~'SLIM' }
        / This line will not appear
      SLIM

      its(:source) { should eq("\n") }
      its(:source_map) { should contain_locations({}) }
    end

    context "with an HTML comment" do
      let(:slim) { <<~'SLIM' }
        /! This line will appear
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        _slim_lint_puts_0
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 1, last_line: 1, last_column: 25},
        })
      end
    end

    context "with an Internet Explorer conditional comment" do
      let(:slim) { <<~'SLIM' }
        /[if IE]
          noscript Get a better browser
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        _slim_lint_puts_0
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 1},
        })
      end
    end

    context "with doctype tag" do
      let(:slim) { <<~'SLIM' }
        doctype xml
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        _slim_lint_puts_0
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 1, last_line: 1, last_column: 12},
        })
      end
    end

    context "with an HTML tag" do
      let(:slim) { <<~'SLIM' }
        p A paragraph
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        _slim_lint_puts_0
        _slim_lint_puts_1
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 1, last_line: 1, last_column: 2},
          2 => {line: 1, column: 3, last_line: 1, last_column: 14},
        })
      end
    end

    context "with an HTML tag with interpolation" do
      let(:slim) { <<~'SLIM' }
        p A #{adjective} paragraph for #{noun}
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        _slim_lint_puts_0
        _slim_lint_puts_1
        output do
          p "x#{adjective}x"
        end
        _slim_lint_puts_2
        output do
          p "x#{noun}x"
        end
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 1, last_line: 1, last_column: 2},
          2 => {line: 1, column: 3, last_line: 1, last_column: 5},
          3 => {line: 1, column: 7, last_line: 1, last_column: 16},
          4 => {line: 1, column: 7 - 2 - 6, last_line: 1, last_column: 16 - 2 - 6},
          5 => {line: 1, column: 7, last_line: 1, last_column: 16},
          6 => {line: 1, column: 17, last_line: 1, last_column: 32},
          7 => {line: 1, column: 34, last_line: 1, last_column: 38},
          8 => {line: 1, column: 34 - 2 - 6, last_line: 1, last_column: 38 - 2 - 6},
          9 => {line: 1, column: 34, last_line: 1, last_column: 38},
        })
      end
    end

    context "with an HTML tag with static attributes" do
      let(:slim) { <<~'SLIM' }
        p class="highlight"
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        _slim_lint_puts_0
        attribute("class") do
          _slim_lint_puts_1
        end
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 1, last_line: 1, last_column: 2},
          2 => {line: 1, column: 3, last_line: 1, last_column: 8},
          3 => {line: 1, column: 10 - 2, last_line: 1, last_column: 19 - 2},
          4 => {line: 1, column: 3, last_line: 1, last_column: 8},
        })
      end
    end

    context "with an HTML tag with Ruby attributes" do
      let(:slim) { <<~'SLIM' }
        p class=user.class id=user.id
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        _slim_lint_puts_0
        attribute("class") do
          user.class
        end
        attribute("id") do
          user.id
        end
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 1, last_line: 1, last_column: 2},
          2 => {line: 1, column: 3, last_line: 1, last_column: 8},
          3 => {line: 1, column: 9 - 2, last_line: 1, last_column: 19 - 2},
          4 => {line: 1, column: 3, last_line: 1, last_column: 8},
          5 => {line: 1, column: 20, last_line: 1, last_column: 22},
          6 => {line: 1, column: 23 - 2, last_line: 1, last_column: 30 - 2},
          7 => {line: 1, column: 20, last_line: 1, last_column: 22},
        })
      end
    end

    context "with a dynamic tag splat" do
      let(:slim) { <<~'SLIM' }
        *some_dynamic_tag Hello World!
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        _slim_lint_puts_0
        some_dynamic_tag
        _slim_lint_puts_1
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 1, last_line: 1, last_column: 1},
          2 => {line: 1, column: 2, last_line: 1, last_column: 18},
          3 => {line: 1, column: 19, last_line: 1, last_column: 31},
        })
      end
    end

    context "with an if statement" do
      let(:slim) { <<~'SLIM' }
        - if condition_true?
          | It's true!
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        if condition_true?
          _slim_lint_puts_0
        end
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 3, last_line: 1, last_column: 21},
          2 => {line: 2, column: 5 - 2, last_line: 2, last_column: 15 - 2},
          3 => {line: 1, column: 1, last_line: 1, last_column: 1},
        })
      end
    end

    context "with an if/else statement" do
      let(:slim) { <<~'SLIM' }
        - if condition_true?
          | It's true!
        - else
          | It's false!
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        if condition_true?
          _slim_lint_puts_0
        else
          _slim_lint_puts_1
        end
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 3, last_line: 1, last_column: 21},
          2 => {line: 2, column: 5 - 2, last_line: 2, last_column: 15 - 2},
          3 => {line: 3, column: 3, last_line: 3, last_column: 7},
          4 => {line: 4, column: 5 - 2, last_line: 4, last_column: 16 - 2},
          5 => {line: 3, column: 1, last_line: 3, last_column: 1},
        })
      end
    end

    context "with an if/elsif/else statement" do
      let(:slim) { <<~'SLIM' }
        - if condition_true?
          | It's true!
        - elsif something_else?
          | ???
        - else
          | It's false!
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        if condition_true?
          _slim_lint_puts_0
        elsif something_else?
          _slim_lint_puts_1
        else
          _slim_lint_puts_2
        end
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 3, last_line: 1, last_column: 21},
          2 => {line: 2, column: 5 - 2, last_line: 2, last_column: 15 - 2},
          3 => {line: 3, column: 3, last_line: 3, last_column: 24},
          4 => {line: 4, column: 5 - 2, last_line: 4, last_column: 8 - 2},
          5 => {line: 5, column: 3, last_line: 5, last_column: 7},
          6 => {line: 6, column: 5 - 2, last_line: 6, last_column: 16 - 2},
          7 => {line: 5, column: 1, last_line: 5, last_column: 1},
        })
      end
    end

    context "with an if/else statement with statements following it" do
      let(:slim) { <<~'SLIM' }
        - if condition_true?
          | It's true!
        - else
          | It's false!
        - following_statement
        - another_statement
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        if condition_true?
          _slim_lint_puts_0
        else
          _slim_lint_puts_1
        end
        following_statement
        another_statement
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 3, last_line: 1, last_column: 21},
          2 => {line: 2, column: 5 - 2, last_line: 2, last_column: 15 - 2},
          3 => {line: 3, column: 3, last_line: 3, last_column: 7},
          4 => {line: 4, column: 5 - 2, last_line: 4, last_column: 16 - 2},
          5 => {line: 3, column: 1, last_line: 3, last_column: 1},
          6 => {line: 5, column: 3, last_line: 5, last_column: 22},
          7 => {line: 6, column: 3, last_line: 6, last_column: 20},
        })
      end
    end

    context "with an output statement with statements following it" do
      let(:slim) { <<~'SLIM' }
        = some_output
        - some_statement
        - another_statement
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        output do
          some_output
        end
        some_statement
        another_statement
      RUBY


      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 1, last_line: 1, last_column: 3},
          2 => {line: 1, column: 3 - 2, last_line: 1, last_column: 14 - 2},
          3 => {line: 1, column: 1, last_line: 1, last_column: 3},
          4 => {line: 2, column: 3, last_line: 2, last_column: 17},
          5 => {line: 3, column: 3, last_line: 3, last_column: 20},
        })
      end
    end

    context "with an output statement that spans multiple lines" do
      let(:slim) { <<~'SLIM' }
        = some_output 1,
                      2,
                      3
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        output do
          some_output 1,
                      2,
                      3
        end
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 1, last_line: 3, last_column: 3},
          2 => {line: 1, column: 3 - 2, last_line: 1, last_column: 17 - 2},
          3 => {line: 2, column: 3 - 2, last_line: 2, last_column: 17 - 2},
          4 => {line: 3, column: 3 - 2, last_line: 3, last_column: 16 - 2},
          5 => {line: 1, column: 1, last_line: 3, last_column: 3},
        })
      end
    end

    context "with a control statement that spans multiple lines" do
      let(:slim) { <<~'SLIM' }
        - some_method 1,
                      2,
                      3
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        some_method 1,
                    2,
                    3
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 1, column: 3, last_line: 1, last_column: 17},
          2 => {line: 2, column: 3, last_line: 2, last_column: 17},
          3 => {line: 3, column: 3, last_line: 3, last_column: 16},
        })
      end
    end

    context "with embedded code" do
      let(:slim) { <<~'SLIM' }
        ruby:
          do_some_setup

          do_some_more_setup


        javascript:
          do_some_javascript
          more_javascript


        css:
          do_some_css { }
          more_css { }


        = do_some_output
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        do_some_setup

        do_some_more_setup


        _slim_lint_puts_0
        _slim_lint_puts_1
        output do
          do_some_output
        end
      RUBY

      its(:source_map) do
        should contain_locations({
          1 => {line: 2, column: 3, last_line: 2, last_column: 16},
          2 => {line: 3, column: 1, last_line: 3, last_column: 1},
          3 => {line: 4, column: 3, last_line: 4, last_column: 21},
          4 => {line: 5, column: 1, last_line: 5, last_column: 1},
          5 => {line: 6, column: 1, last_line: 6, last_column: 1},
          6 => {line: 7, column: 1, last_line: 11, last_column: 1},
          7 => {line: 12, column: 1, last_line: 16, last_column: 1},
          8 => {line: 17, column: 1, last_line: 17, last_column: 3},
          9 => {line: 17, column: 3 - 2, last_line: 17, last_column: 17 - 2},
          10 => {line: 17, column: 1, last_line: 17, last_column: 3},
        })
      end
    end

    context "Ruby attribute values retain their whitespace" do
      let(:slim) { <<~'SLIM' }
        tag attr=[ :array, :with, :whitespace ]
      SLIM

      its(:source) { should eq(<<~'RUBY') }
        _slim_lint_puts_0
        attribute("attr") do
          [ :array, :with, :whitespace ]
        end
      RUBY
    end
  end
end

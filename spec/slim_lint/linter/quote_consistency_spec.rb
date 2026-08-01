# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::QuoteConsistency do
  include_context 'linter'

  context 'when file has no quotes' do
    let(:slim) { <<-SLIM }
      .container
      p Hello World
    SLIM

    it { should_not report_lint }
  end

  context 'when file has double quotes' do
    let(:slim) { <<-SLIM }
      .title "Hello World"
    SLIM

    context 'when enforced_style is double_quotes' do
      let(:config) { { 'enforced_style' => 'double_quotes' } }

      it { should_not report_lint }
    end

    context 'when enforced_style is single_quotes' do
      it { should report_lint line: 1 }
    end
  end

  context 'when file has single quotes' do
    let(:slim) { <<-SLIM }
      .title 'Hello World'
    SLIM

    context 'when enforced_style is double_quotes' do
      let(:config) { { 'enforced_style' => 'double_quotes' } }

      it { should report_lint line: 1 }
    end

    context 'when enforced_style is single_quotes' do
      it { should_not report_lint }
    end
  end

  context 'when line has nested quotes' do
    let(:slim) { <<-SLIM }
      .title "Hello 'World'!"
      .title 'Hello "World"!'
    SLIM

    context 'when enforced_style is single_quotes' do
      let(:config) { { 'enforced_style' => 'single_quotes' } }

      it { should_not report_lint }
    end

    context 'when enforced_style is double_quotes' do
      let(:config) { { 'enforced_style' => 'double_quotes' } }

      it { should_not report_lint }
    end
  end

  context 'when line has multiple quoted strings' do
    let(:slim) { <<-SLIM }
      .input name='test-name' value="test-value"
    SLIM

    it { should report_lint line: 1 }
  end

  context 'when file has comments with quotes' do
    let(:slim) { <<-SLIM }
      / Hello "World"
    SLIM

    it { should_not report_lint }
  end

  context 'when file has ruby lines with quotes' do
    let(:slim) { <<-SLIM }
      - title = "Hello World"
    SLIM

    it { should_not report_lint }
  end

  context 'autocorrect support' do
    let(:slim) { <<-SLIM }
      .container
    SLIM

    it 'is declared' do
      described_class.supports_autocorrect?.should == true
    end
  end

  describe 'correction' do
    context 'when enforcing single quotes on a line with double quotes' do
      let(:slim) { <<-SLIM }
        .title "Hello World"
      SLIM

      it 'swaps double quotes for single quotes' do
        subject.lints.first.correction.call('.title "Hello World"')
               .should == ".title 'Hello World'"
      end

      context 'when the attribute contains a quoted expression' do
        let(:slim) { %{.button title="Hello" data='He said "Hello"'} }

        it 'preserves the nested quote characters' do
          source = %{.button title="Hello" data='He said "Hello"'}
          subject.lints.first.correction.call(source)
                 .should == %{.button title='Hello' data='He said "Hello"'}
        end
      end
    end

    context 'when enforcing double quotes on a line with single quotes' do
      let(:config) { { 'enforced_style' => 'double_quotes' } }
      let(:slim) { <<-SLIM }
        .title 'Hello World'
      SLIM

      it 'swaps single quotes for double quotes' do
        subject.lints.first.correction.call(".title 'Hello World'")
               .should == '.title "Hello World"'
      end
    end
  end
end

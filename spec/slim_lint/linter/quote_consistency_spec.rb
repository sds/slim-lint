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
      .input name='name' value="value"
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

    context 'when skip_ruby_lines is true' do
      let(:config) { { 'skip_ruby_lines' => true } }

      it { should_not report_lint }
    end

    context 'when skip_ruby_lines is false' do
      let(:config) { { 'skip_ruby_lines' => false } }

      it { should report_lint line: 1 }
    end
  end
end

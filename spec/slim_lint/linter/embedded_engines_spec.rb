# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::EmbeddedEngines do
  include_context 'linter'

  context 'default configuration' do
    let(:slim) { <<-SLIM }
      h1 heading

      javascript:
        alert('foo')

      css:
        h1 {
          font-size: 10px;
        }
    SLIM

    it { should_not report_lint }
  end

  context 'when a file contains forbidden embedded engine' do
    let(:config) do
      { 'forbidden_engines' => %w[javascript css] }
    end

    let(:slim) { <<-SLIM }
      h1 heading

      javascript:
        alert('foo')

      css:
        h1 {
          font-size: 10px;
        }
    SLIM

    it { should report_lint line: 3 }
    it { should report_lint line: 6 }
  end

  context 'when a file contains nested forbidden embedded engine' do
    let(:config) do
      { 'forbidden_engines' => %w[javascript css] }
    end

    let(:slim) { <<-SLIM }
      html
        head
          javascript:
            alert('foo')

          css:
            h1 {
              font-size: 10px;
            }
        body
          h1 Test
    SLIM

    it { should report_lint line: 3 }
    it { should report_lint line: 6 }
  end
end

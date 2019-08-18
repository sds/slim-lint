# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::CommentControlStatement do
  include_context 'linter'

  context 'when a control statement contains code' do
    let(:slim) { '- some_code' }

    it { should_not report_lint }
  end

  context 'when a control statement contains only a comment' do
    let(:slim) { <<-SLIM }
      -# A comment
      - # Another comment testing leading whitespace
    SLIM

    it { should report_lint line: 1 }
    it { should report_lint line: 2 }
  end

  context 'when a control statement contains a RuboCop directive' do
    let(:slim) { <<-SLIM }
      -# rubocop:disable Metrics/LineLength
      - some_code
      -# rubocop:enable Metrics/LineLength
    SLIM

    it { should_not report_lint }
  end
end

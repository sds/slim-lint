# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::Tab do
  include_context 'linter'

  context 'when with ZWSP' do
    let(:slim) { <<-SLIM }
      | Hello ZWSP\u200b
    SLIM

    it { should report_lint line: 1 }
  end

  context 'when without ZWSP' do
    let(:slim) { <<-SLIM }
      | Hello without ZWSP
    SLIM

    it { should_not report_lint }
  end
end

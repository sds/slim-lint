# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::Zwsp do
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

  context 'autocorrect support' do
    let(:slim) { '' }

    it 'is declared' do
      described_class.supports_autocorrect?.should == true
    end
  end

  describe 'correction' do
    let(:slim) { '| Hello ZWSP​' }

    it 'removes the zero-width space' do
      subject.lints.first.correction.call('| Hello ZWSP​')
             .should == '| Hello ZWSP'
    end
  end
end

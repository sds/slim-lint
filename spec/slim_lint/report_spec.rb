# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Report do
  let(:linter) { double('linter') }
  let(:files) { ['some-filename.slim'] }

  def lint_for(corrected: false)
    lint = SlimLint::Lint.new(linter, 'some-filename.slim', 1, 'Some message')
    lint.corrected = corrected
    lint
  end

  describe '#failed?' do
    subject { described_class.new(lints, files).failed? }

    context 'when there are no lints' do
      let(:lints) { [] }

      it { should == false }
    end

    context 'when there are uncorrected lints' do
      let(:lints) { [lint_for(corrected: false)] }

      it { should == true }
    end

    context 'when every lint has been corrected' do
      let(:lints) { [lint_for(corrected: true)] }

      it { should == false }
    end

    context 'when some lints have been corrected but others have not' do
      let(:lints) { [lint_for(corrected: true), lint_for(corrected: false)] }

      it { should == true }
    end
  end
end

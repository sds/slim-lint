# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::TagCase do
  include_context 'linter'

  context 'when a tag is all lowercase' do
    let(:slim) { 'img src="images/cat.gif"' }

    it { should_not report_lint }
  end

  context 'when a tag contains uppercase characters' do
    let(:slim) { 'IMG src="images/cat.gif"' }

    it { should report_lint line: 1 }
  end

  context 'autocorrect support' do
    let(:slim) { '' }

    it 'is declared' do
      described_class.supports_autocorrect?.should == true
    end
  end

  describe 'correction' do
    let(:slim) { 'IMG src="images/cat.gif"' }

    it 'downcases the offending tag name' do
      subject.lints.first.correction.call('IMG src="images/cat.gif"')
             .should == 'img src="images/cat.gif"'
    end

    context 'when indented' do
      let(:slim) { "tag\n  IMG src=\"images/cat.gif\"\n" }

      it 'only downcases the tag name, preserving indentation' do
        subject.lints.first.correction.call('  IMG src="images/cat.gif"')
               .should == '  img src="images/cat.gif"'
      end
    end
  end
end

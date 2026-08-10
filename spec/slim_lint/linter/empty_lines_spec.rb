# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::EmptyLines do
  include_context 'linter'

  context 'when first line is blank' do
    let(:slim) { "\n.style" }

    it { should report_lint line: 1 }
  end

  context '2 lines in a row are empty' do
    let(:slim) { ".style\n\n\n.other" }

    it { should report_lint line: 3 }
  end

  context '3 lines in a row are empty' do
    let(:slim) { ".style\n\n\n\n.other" }

    it { should report_lint line: 3 }
  end

  context 'line between instructions is empty' do
    let(:slim) { ".style\n\n.other" }

    it { should_not report_lint }
  end

  context 'autocorrect support' do
    let(:slim) { '' }

    it 'is declared' do
      described_class.supports_autocorrect?.should == true
    end
  end

  describe 'correction' do
    let(:slim) { ".style\n\n\n.other" }

    it 'removes the extra line' do
      subject.lints.first.correction.call('').should be_nil
    end

    context 'when applied via the corrector' do
      it 'collapses consecutive blank lines down to one' do
        document = SlimLint::Document.new(normalize_indent(slim), config: config)
        subject.run(document)
        SlimLint::Corrector.new(document).correct(subject.lints)
                           .should == ".style\n\n.other"
      end
    end

    context 'when the file starts with a blank line' do
      let(:slim) { "\n.style" }

      it 'removes the leading blank line' do
        document = SlimLint::Document.new(normalize_indent(slim), config: config)
        subject.run(document)
        SlimLint::Corrector.new(document).correct(subject.lints)
                           .should == '.style'
      end
    end
  end
end

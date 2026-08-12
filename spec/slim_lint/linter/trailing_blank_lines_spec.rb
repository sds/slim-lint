# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::TrailingBlankLines do
  include_context 'linter'

  context 'when line does not have line feed' do
    let(:slim) { '.style' }

    it { should report_lint line: 1 }
  end

  context 'when last line does not have line feed' do
    let(:slim) { ".style\n  .other" }

    it { should report_lint line: 2 }
  end

  context 'when line contains multiple trailing newline' do
    let(:slim) { ".style\n\n" }

    it { should report_lint line: 2 }
  end

  context 'when line contains trailing newline' do
    let(:slim) { ".style\n" }

    it { should_not report_lint }
  end

  context 'when last line does not have line feed' do
    let(:slim) { ".style\n  .other\n" }

    it { should_not report_lint }
  end

  context 'when source is empty' do
    let(:slim) { '' }

    it { should_not report_lint }
  end

  context 'autocorrect support' do
    let(:slim) { '' }

    it 'is declared' do
      described_class.supports_autocorrect?.should == true
    end
  end

  describe 'correction' do
    context 'when the final newline is missing' do
      let(:slim) { '.style' }

      it 'appends a trailing newline' do
        subject.lints.first.correction.call('.style').should == ".style\n"
      end

      it 'adds exactly one newline when applied via the corrector' do
        document = SlimLint::Document.new('.style', config: config)
        subject.run(document)
        SlimLint::Corrector.new(document).correct(subject.lints)
                           .should == ".style\n"
      end
    end

    context 'when there are extra blank lines at the end of the file' do
      let(:slim) { ".style\n\n" }

      it 'removes the offending line' do
        subject.lints.first.correction.call("\n").should be_nil
      end

      it 'leaves a single trailing newline when applied via the corrector' do
        document = SlimLint::Document.new(".style\n\n", config: config)
        subject.run(document)
        SlimLint::Corrector.new(document).correct(subject.lints)
                           .should == ".style\n"
      end
    end
  end
end

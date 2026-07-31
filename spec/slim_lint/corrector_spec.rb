# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Corrector do
  let(:config) { SlimLint::ConfigurationLoader.default_configuration }
  let(:document) { SlimLint::Document.new(source, config: config) }

  let(:linter) { double('linter') }

  def lint_for(line, correction: nil)
    SlimLint::Lint.new(linter, document.file, line, 'Some message', :warning,
                       correction: correction)
  end

  describe '#correct' do
    subject { described_class.new(document).correct(lints) }

    context 'when no lints are correctable' do
      let(:source) { "p Hello \np World \n" }
      let(:lints) { [lint_for(1), lint_for(2)] }

      it 'returns the source unchanged' do
        subject.should == document.source
      end

      it 'does not mark any lints as corrected' do
        subject
        lints.none?(&:corrected?).should == true
      end
    end

    context 'when a lint has a correction' do
      let(:source) { "p Hello \np World\n" }
      let(:lints) { [lint_for(1, correction: lambda(&:rstrip))] }

      it 'applies the correction to the offending line' do
        subject.should == "p Hello\np World\n"
      end

      it 'marks the lint as corrected' do
        subject
        lints.first.corrected?.should == true
      end

      it 'leaves lines without a correction untouched' do
        subject.lines[1].should == "p World\n"
      end
    end

    context 'when multiple lints correct the same line' do
      let(:source) { "p 'Hello' \n" }
      let(:lints) do
        [
          lint_for(1, correction: lambda(&:rstrip)),
          lint_for(1, correction: ->(line) { line.tr("'", '"') }),
        ]
      end

      it 'applies every correction to that line, in order' do
        subject.should == "p \"Hello\"\n"
      end

      it 'marks every applied lint as corrected' do
        subject
        lints.all?(&:corrected?).should == true
      end
    end

    context 'when the source does not end with a trailing newline' do
      let(:source) { 'p Hello ' }
      let(:lints) { [lint_for(1, correction: lambda(&:rstrip))] }

      it 'does not add one' do
        subject.should == 'p Hello'
      end
    end
  end
end

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

    context 'when a correction returns nil' do
      let(:source) { "p Hello\n-\np World\n" }
      let(:lints) { [lint_for(2, correction: ->(_line) { nil })] }

      it 'removes the line entirely' do
        subject.should == "p Hello\np World\n"
      end

      it 'marks the lint as corrected' do
        subject
        lints.first.corrected?.should == true
      end
    end

    context 'when multiple lines are removed' do
      let(:source) { "p Hello\n-\n-\np World\n" }
      let(:lints) do
        [
          lint_for(2, correction: ->(_line) { nil }),
          lint_for(3, correction: ->(_line) { nil }),
        ]
      end

      it 'removes both lines without disturbing the others' do
        subject.should == "p Hello\np World\n"
      end
    end

    context 'when a correction returns a string with an embedded newline' do
      let(:source) { 'p Hello' }
      let(:lints) { [lint_for(1, correction: ->(line) { "#{line}\n" })] }

      it 'splits it into multiple lines' do
        subject.should == "p Hello\n"
      end
    end

    context 'when a line-adding correction is on the last line of a multi-line file' do
      let(:source) { "p Hello\np World" }
      let(:lints) do
        [
          lint_for(1, correction: lambda(&:upcase)),
          lint_for(2, correction: ->(line) { "#{line}\n" }),
        ]
      end

      it 'does not corrupt earlier, already-processed corrections' do
        subject.should == "P HELLO\np World\n"
      end
    end

    context 'when a correction removes a line before another correction' do
      let(:source) { "p One\n-\np Two\np Three \n" }
      let(:lints) do
        [
          lint_for(2, correction: ->(_line) { nil }),
          lint_for(4, correction: lambda(&:rstrip)),
        ]
      end

      it 'applies both corrections using their original line numbers' do
        subject.should == "p One\np Two\np Three\n"
      end
    end

    context 'when a correction on a line makes a later correction on the same line moot' do
      let(:source) { "p Hello\n-\n" }
      let(:lints) do
        [
          lint_for(2, correction: ->(_line) { nil }),
          lint_for(2, correction: ->(_line) { raise 'should not be called' }),
        ]
      end

      it 'skips the later correction' do
        subject.should == "p Hello\n"
      end

      it 'does not mark the skipped correction as corrected' do
        subject
        lints.last.corrected?.should == false
      end
    end
  end
end

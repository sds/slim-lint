# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::EmptyControlStatement do
  include_context 'linter'

  context 'when a control statement contains code' do
    let(:slim) { '- some_code' }

    it { should_not report_lint }
  end

  context 'when a control statement contains no code' do
    let(:slim) { '-' }

    it { should report_lint line: 1 }
  end

  context 'autocorrect support' do
    let(:slim) { '' }

    it 'is declared' do
      described_class.supports_autocorrect?.should == true
    end
  end

  describe 'correction' do
    let(:slim) { '-' }

    it 'removes the line' do
      subject.lints.first.correction.call('-').should be_nil
    end

    context 'when applied via the corrector' do
      let(:slim) { "p Hello\n-\np World\n" }

      it 'removes the empty control statement entirely' do
        document = SlimLint::Document.new(normalize_indent(slim), config: config)
        subject.run(document)
        SlimLint::Corrector.new(document).correct(subject.lints)
                           .should == "p Hello\np World\n"
      end
    end
  end
end

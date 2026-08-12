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
      -# rubocop:disable Layout/LineLength
      - some_code
      -# rubocop:enable Layout/LineLength
    SLIM

    it { should_not report_lint }
  end

  context 'when a control statement contains a Rails Template Dependency directive' do
    let(:slim) { <<-SLIM }
      -# Template Dependency: some/partial
      = render some_helper_method_that_returns_a_partial_name
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
    let(:slim) { '-# A comment' }

    it 'replaces the control statement comment with a Slim comment' do
      subject.lints.first.correction.call('-# A comment')
             .should == '/ A comment'
    end

    context 'when there is a space between the `-` and `#`' do
      let(:slim) { '- # Another comment' }

      it 'replaces the control statement comment with a Slim comment' do
        subject.lints.first.correction.call('- # Another comment')
               .should == '/ Another comment'
      end
    end

    context 'when indented' do
      let(:slim) { "p\n  -# A comment\n" }

      it 'only replaces the comment, preserving indentation' do
        subject.lints.first.correction.call('  -# A comment')
               .should == '  / A comment'
      end
    end
  end
end

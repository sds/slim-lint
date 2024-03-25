# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::StrictLocalsMissing do
  include_context 'linter'

  context 'when magic line defines strict locals' do
    let(:slim) { '/# locals: (foo:, bar:)' }

    it { should_not report_lint }
  end

  context 'when magic line defines empty strict locals' do
    let(:slim) { '/# locals: ()' }

    it { should_not report_lint }
  end

  context 'when magic line is not at the top of the file' do
    let(:slim) { <<-SLIM }
      h1 Hello
      = call(foo, bar)
      /# locals: (foo:, bar:)
    SLIM

    it { should_not report_lint }
  end

  context 'when template has no strict locals definition' do
    let(:slim) { 'h1 hello' }

    it { should report_lint }
  end
end

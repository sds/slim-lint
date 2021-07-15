# frozen_string_literal: true

require 'spec_helper'

describe 'Config comments' do
  include_context 'linter'

  let(:described_class) { SlimLint::Linter::TagCase }

  context '' do
    let(:slim) { <<-SLIM }
      IMG src="images/cat.gif"

      / slim-lint:disable TagCase
      IMG src="images/cat.gif"
      / slim-lint:enable TagCase

      IMG src="images/cat.gif"
    SLIM

    it { should report_lint line: 1 }
    it { should_not report_lint line: 4 }
    it { should report_lint line: 7 }
  end
end

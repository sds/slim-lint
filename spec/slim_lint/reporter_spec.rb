require 'spec_helper'

describe SlimLint::Reporter do
  let(:reporter) { SlimLint::Reporter.new }

  describe '#report_lints' do
    subject { reporter.report_lints }

    it 'raises an error' do
      expect { subject }.to raise_error NotImplementedError
    end
  end
end

require 'spec_helper'

describe SlimLint::Filters::InjectLineNumbers do
  describe '#call' do
    let(:sexp) { SlimLint::Sexp.new([:one, [:newline], [:two, [:newline], :three]]) }
    subject { described_class.new.call(sexp) }

    it 'calculates line numbers correctly' do
      subject.line == 1
      subject[1].line == 2
      subject[2][1].line == 3
    end
  end
end

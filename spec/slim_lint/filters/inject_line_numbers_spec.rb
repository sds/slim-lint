require 'spec_helper'

describe SlimLint::Filters::InjectLineNumbers do
  describe '#call' do
    subject { described_class.new.call(sexp) }

    let(:sexp) { SlimLint::Sexp.new([:one, [:newline], [:two, [:newline], :three]]) }

    it 'calculates line numbers correctly' do
      subject.line.should == 1
      subject[1].line.should == 1
      subject[2][0].line.should == 2
      subject[2][1].line.should == 2
      subject[2][2].line.should == 3
    end

    context 'when a Sexp has atoms spanning multiple lines' do
      let(:sexp) { SlimLint::Sexp.new(["one\ntwo", [:newline], ["three\nfour", [:newline], 5]]) }

      it 'calculates line numbers correctly' do
        subject.line.should == 1
        subject[1].line.should == 2
        subject[2][0].line.should == 3
        subject[2][1].line.should == 4
        subject[2][2].line.should == 5
      end
    end
  end
end

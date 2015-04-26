require 'spec_helper'

describe SlimLint::Linter do
  let(:linter_class) do
    Class.new(described_class) do
      on [:lint] do |sexp|
        report_lint(sexp, 'A lint!')
      end
    end
  end

  let(:config) { double }
  let(:linter) { linter_class.new(config) }

  describe '#run' do
    let(:document) do
      double(sexp: SlimLint::Sexp.new([:one, [:lint], :two, [:lint]]),
             file: 'file.slim')
    end

    subject { linter.run(document) }

    it 'returns the reported lints' do
      subject.length == 2
    end
  end

  describe '#name' do
    subject { linter.name }

    before do
      linter.class.stub(:name).and_return('SlimLint::Linter::SomeLinterName')
    end

    it { should == 'SomeLinterName' }
  end
end

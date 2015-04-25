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

  subject { linter_class.new(config) }

  describe '#run' do
    let(:document) do
      double(sexp: SlimLint::Sexp.new([:one, [:lint], :two, [:lint]]),
             file: 'file.slim')
    end

    subject { super().run(document) }

    it 'returns the reported lints' do
      subject.length == 2
    end
  end
end

require 'spec_helper'

describe SlimLint::Engine do
  describe '#parse' do
    subject { described_class.new.parse(source) }

    context 'with invalid source' do
      let(:source) { '%haml?' }

      it 'raises an error' do
        expect { subject }.to raise_error Slim::Parser::SyntaxError
      end
    end

    context 'with valid source' do
      let(:source) { normalize_indent(<<-SLIM) }
        doctype html
        head
          title My title
      SLIM

      it 'parses' do
        subject.match?([:multi, [:html, :doctype]]).should == true
      end

      it 'injects line numbers' do
        subject.line.should == 1
      end
    end
  end
end

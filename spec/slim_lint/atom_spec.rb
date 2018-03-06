# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Atom do
  describe '#==' do
    let(:value) { :atom }
    subject { described_class.new(value) == other }

    context 'when compared to an equivalent atom' do
      let(:other) { described_class.new(:atom) }

      it { should == true }
    end

    context 'when compared to a non-equivalent atom' do
      let(:other) { described_class.new(:mismatch) }

      it { should == false }
    end

    context 'when compared to a literal value matching the wrapped value' do
      let(:other) { :atom }

      it { should == true }
    end

    context 'when compared to a literal value not matching the wrapped value' do
      let(:other) { :mismatch }

      it { should == false }
    end
  end

  describe '#match?' do
    let(:value) { :atom }
    subject { described_class.new(value).match?(pattern) }

    context 'when pattern is an expression' do
      let(:pattern) { [:one, :two] }

      it { should == false }
    end

    context 'when pattern is the same literal value as the wrapped value' do
      let(:pattern) { value }

      it { should == true }
    end

    context 'when pattern is a different literal value than the wrapped value' do
      let(:pattern) { :mismatch }

      it { should == false }
    end
  end

  describe '#to_s' do
    let(:value) { [1, 2, '3'] }
    subject { described_class.new(value).to_s }

    it { should == value.to_s }
  end

  describe '#inspect' do
    let(:value) { [1, 2, '3'] }
    subject { described_class.new(value).inspect }

    it { should == "<#Atom #{value.inspect}>" }
  end

  describe '#method_missing' do
    let(:value) { [1, 2, 3] }
    let(:atom) { described_class.new(value) }
    subject { atom.send(method_name) }

    context 'when the method is not defined by the Atom class' do
      context 'and the method name exists on the wrapped object' do
        let(:method_name) { :length }

        it 'calls the method on the wrapped object' do
          atom.instance_variable_get(:@value).should_receive(:length)
          subject
        end
      end

      context 'and the method name does not exist on the wrapped object' do
        let(:method_name) { :uh_oh }

        it 'raises method missing' do
          expect { subject }.to raise_error NoMethodError
        end
      end
    end
  end

  describe '#respond_to?' do
    let(:value) { [1, 2, 3] }
    let(:atom) { described_class.new(value) }
    subject { atom.respond_to?(method_name) }

    context 'when the method is defined by the Atom class' do
      let(:method_name) { :match? }

      it { should == true }
    end

    context 'when the method is not defined by the Atom class' do
      context 'and the method name exists on the wrapped object' do
        let(:method_name) { :length }

        it { should == true }
      end

      context 'and the method name does not exist on the wrapped object' do
        let(:method_name) { :uh_oh }

        it { should == false }
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Lint do
  let(:linter) { double('linter') }
  let(:filename) { 'some-filename.slim' }
  let(:line) { 5 }
  let(:message) { 'Some message' }

  describe '#correctable?' do
    subject do
      described_class.new(linter, filename, line, message, :warning, correction: correction)
    end

    context 'when a correction was given' do
      let(:correction) { lambda(&:rstrip) }

      it { subject.correctable?.should == true }
    end

    context 'when no correction was given' do
      let(:correction) { nil }

      it { subject.correctable?.should == false }
    end
  end

  describe '#corrected?' do
    subject { described_class.new(linter, filename, line, message) }

    it 'defaults to false' do
      subject.corrected?.should == false
    end

    it 'becomes true after being marked corrected' do
      subject.corrected = true
      subject.corrected?.should == true
    end
  end
end

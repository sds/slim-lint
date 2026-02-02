# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Configuration do
  let(:config) { SlimLint::ConfigurationLoader.default_configuration }

  describe '#initialize' do
    let(:config) { described_class.new(hash) }
    subject { config }

    context 'with an empty hash' do
      let(:hash) { {} }

      it 'creates an empty `exclude` section' do
        subject['exclude'].should == []
      end

      it 'creates an empty `linters` section' do
        subject['linters'].should == {}
      end
    end

    context 'with a linter with single values in its `include`/`exclude` options' do
      let(:hash) do
        {
          'linters' => {
            'Tab' => {
              'include' => '**/*.slim',
              'exclude' => '**/*.ignore.slim',
            },
          },
        }
      end

      it 'converts the `include` value into an array' do
        subject['linters']['Tab']['include'].should == ['**/*.slim']
      end

      it 'converts the `exclude` value into an array' do
        subject['linters']['Tab']['exclude'].should == ['**/*.ignore.slim']
      end
    end

    context 'with an invalid linter name' do
      let(:hash) do
        {
          'linters' => {
            'InvalidLinterName' => {
              'enabled' => false,
            },
          },
        }
      end

      it 'raises a NoSuchLinter error' do
        expect { subject }.to raise_error(SlimLint::NoSuchLinter, /InvalidLinterName/)
      end
    end
  end

  describe '#for_linter' do
    subject { config.for_linter(linter) }

    context 'when linter is a Class' do
      let(:linter) { SlimLint::Linter::LineLength }

      it 'returns the configuration for the relevant linter' do
        subject['max'].should == 80
      end
    end

    context 'when linter is a Linter' do
      let(:linter) { SlimLint::Linter::LineLength.new(double) }

      it 'returns the configuration for the relevant linter' do
        subject['max'].should == 80
      end
    end
  end
end

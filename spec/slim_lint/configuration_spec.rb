require 'spec_helper'

describe SlimLint::Configuration do
  let(:config) { SlimLint::ConfigurationLoader.default_configuration }

  describe '#initialize' do
    let(:config) { described_class.new(hash) }
    subject { config }

    context 'with an empty hash' do
      let(:hash) { {} }

      it 'creates an empty `linters` section' do
        subject['linters'].should == {}
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

require 'spec_helper'

describe SlimLint::Runner do
  let(:options) { {} }
  let(:runner)  { described_class.new }

  before do
    runner.stub(:extract_applicable_files).and_return(files)
  end

  describe '#run' do
    let(:files) { %w[file1.slim file2.slim] }
    let(:mock_linter) { double('linter', lints: [], name: 'Blah') }

    let(:options) do
      {
        files: files,
      }
    end

    subject { runner.run(options) }

    before do
      runner.stub(:collect_lints).and_return([])
    end

    it 'searches for lints in each file' do
      runner.should_receive(:collect_lints).exactly(files.size).times
      subject
    end

    context 'when :config_file option is specified' do
      let(:options) { { config_file: 'some-config.yml' } }
      let(:config) { double('config') }

      it 'loads that specified configuration file' do
        config.stub(:for_linter).and_return('enabled' => true)

        SlimLint::ConfigurationLoader.should_receive(:load_file)
                                     .with('some-config.yml')
                                     .and_return(config)
        subject
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

require 'slim_lint/options'

describe SlimLint::Options do
  describe '#parse' do
    subject { super().parse(args) }
    let(:args) { [] }

    context 'with a configuration file specified' do
      let(:args) { %w[--config some-config.yml] }

      it 'sets the `config_file` option to that file path' do
        subject.should include config_file: 'some-config.yml'
      end
    end

    context 'with a list of files to exclude' do
      let(:args) { %w[--exclude some-glob-pattern/*.slim,some-other-pattern.slim] }

      it 'sets the `excluded_files` option to that list of patterns' do
        subject.should include excluded_files: %w[some-glob-pattern/*.slim some-other-pattern.slim]
      end
    end

    context 'with a list of linters to include' do
      let(:args) { %w[--include-linter SomeLinter,SomeOtherLinter] }

      it 'sets the `included_linters` option to that list of linters' do
        subject.should include included_linters: %w[SomeLinter SomeOtherLinter]
      end
    end

    context 'with a list of linters to exclude' do
      let(:args) { %w[--exclude-linter SomeLinter,SomeOtherLinter] }

      it 'sets the `excluded_linters` option to that list of linters' do
        subject.should include excluded_linters: %w[SomeLinter SomeOtherLinter]
      end
    end

    context 'with a reporter option' do
      context 'for a reporter that exists' do
        let(:args) { %w[--reporter Json] }

        it 'sets the `reporter` option' do
          subject.should include reporter: SlimLint::Reporter::JsonReporter
        end
      end

      context 'for a reporter that exists when capitalized' do
        let(:args) { %w[--reporter json] }

        it 'sets the `reporter` option' do
          subject.should include reporter: SlimLint::Reporter::JsonReporter
        end
      end

      context 'for a reporter that does not exist' do
        let(:args) { %w[--reporter NonExistent] }

        it 'raises an error' do
          expect { subject }.to raise_error SlimLint::Exceptions::InvalidCLIOption
        end
      end
    end

    context 'with the help option' do
      let(:args) { ['--help'] }

      it 'returns usage information in the `help` option' do
        subject[:help].should =~ /Usage/i
      end
    end

    context 'with the version option' do
      let(:args) { ['--version'] }

      it 'sets the `version` option' do
        subject.should include version: true
      end
    end

    context 'with the verbose version option' do
      let(:args) { ['--verbose-version'] }

      it 'sets the `verbose_version` option' do
        subject.should include verbose_version: true
      end
    end

    context 'color' do
      describe 'manually on' do
        let(:args) { ['--color'] }

        it 'sets the `color` option to true' do
          subject.should include color: true
        end
      end

      describe 'manually off' do
        let(:args) { ['--no-color'] }

        it 'sets the `color option to false' do
          subject.should include color: false
        end
      end
    end

    context 'with a list of file glob patterns' do
      let(:args) { %w[app/**/*.slim some-dir/some-template.slim] }

      it 'sets the `files` option to that list of patterns' do
        subject.should include files: args
      end
    end

    context 'with an invalid argument' do
      let(:args) { ['--some-invalid-argument'] }

      it 'raises an invalid CLI option error' do
        expect { subject }.to raise_error SlimLint::Exceptions::InvalidCLIOption
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Reporter::GithubReporter do
  describe '#display_report' do
    let(:io) { StringIO.new }
    let(:output) { io.string }
    let(:logger) { SlimLint::Logger.new(io) }
    let(:report) { SlimLint::Report.new(lints, []) }
    let(:reporter) { described_class.new(logger) }

    subject { reporter.display_report(report) }

    context 'when there are no lints' do
      let(:lints) { [] }

      it 'prints nothing' do
        subject
        output.should be_empty
      end
    end

    context 'when there are lints' do
      let(:filenames)    { ['some-filename.slim', 'other-filename.slim'] }
      let(:lines)        { [502, 724] }
      let(:descriptions) { ['Description of lint 1', 'Description of lint 2'] }
      let(:severities)   { [:warning] * 2 }
      let(:linter)       { double(name: 'SomeLinter') }

      let(:lints) do
        filenames.each_with_index.map do |filename, index|
          SlimLint::Lint.new(linter, filename, lines[index], descriptions[index], severities[index])
        end
      end

      it 'prints each lint on its own line' do
        subject
        output.count("\n").should == 2
      end

      it 'prints a trailing newline' do
        subject
        output[-1].should == "\n"
      end

      it 'prints the filename in the "file" parameter for each lint' do
        subject
        filenames.each do |filename|
          output.scan(/file=#{filename}/).count.should == 1
        end
      end

      it 'prints the line number in the "line" parameter for each lint' do
        subject
        lines.each do |line|
          output.scan(/line=#{line}/).count.should == 1
        end
      end

      it 'prints a "Slim Lint" annotation title for each lint' do
        subject
        output.scan(/title=Slim Lint/).count.should == 2
      end

      it 'prints the description for each lint at the end of the line' do
        subject
        descriptions.each do |description|
          output.scan(/::#{description}$/).count.should == 1
        end
      end

      context 'when lints are warnings' do
        it 'prints the warning severity annotation at the beginning of each line' do
          subject
          output.split("\n").each do |line|
            line.scan(/^::warning /).count.should == 1
          end
        end
      end

      context 'when lints are errors' do
        let(:severities) { [:error] * 2 }

        it 'prints the error severity annotation at the beginning of each line' do
          subject
          output.split("\n").each do |line|
            line.scan(/^::error /).count.should == 1
          end
        end
      end

      context 'when lint has no associated linter' do
        let(:linter) { nil }

        it 'prints the description for each lint' do
          subject
          descriptions.each do |description|
            output.scan(/#{description}/).count.should == 1
          end
        end
      end
    end
  end
end

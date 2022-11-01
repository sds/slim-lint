# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Reporter::EmacsReporter do
  describe "#display_report" do
    let(:io) { StringIO.new }
    let(:output) { io.string }
    let(:logger) { SlimLint::Logger.new(io) }
    let(:report) { SlimLint::Report.new(lints, []) }
    let(:reporter) { described_class.new(logger) }

    subject { reporter.display_report(report) }

    context "when there are no lints" do
      let(:lints) { [] }

      it "prints nothing" do
        subject
        output.should be_empty
      end
    end

    context "when there are lints" do
      let(:filenames) { ["some-filename.slim", "other-filename.slim"] }
      let(:lines) { [502, 724] }
      let(:descriptions) { ["Description of lint 1", "Description of lint 2"] }
      let(:severities) { [:warning] * 2 }
      let(:linter) { double(name: "SomeLinter") }

      let(:lints) do
        filenames.each_with_index.map do |filename, index|
          location = SlimLint::SourceLocation.new(start_line: lines[index], start_column: index + 1)
          SlimLint::Lint.new(linter, filename, location, descriptions[index], severities[index])
        end
      end

      it "prints each lint on its own line" do
        subject
        output.count("\n").should eq(2)
      end

      it "prints a trailing newline" do
        subject
        output[-1].should eq("\n")
      end

      it "prints the filename for each lint" do
        subject
        filenames.each do |filename|
          output.scan(/#{filename}/).count.should eq(1)
        end
      end

      it "prints the line number for each lint" do
        subject
        lines.each do |line|
          output.scan(/#{line}/).count.should eq(1)
        end
      end

      it "prints the description for each lint" do
        subject
        descriptions.each do |description|
          output.scan(/#{description}/).count.should eq(1)
        end
      end

      context "when lints are warnings" do
        it "prints the warning severity code on each line" do
          subject
          output.split("\n").each do |line|
            line.scan(/W:/).count.should eq(1)
          end
        end
      end

      context "when lints are errors" do
        let(:severities) { [:error] * 2 }

        it "prints the error severity code on each line" do
          subject
          output.split("\n").each do |line|
            line.scan(/E:/).count.should eq(1)
          end
        end
      end

      context "when lint has no associated linter" do
        let(:linter) { nil }

        it "prints the description for each lint" do
          subject
          descriptions.each do |description|
            output.scan(/#{description}/).count.should eq(1)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Reporter::JsonReporter do
  describe "#display_report" do
    let(:io) { StringIO.new }
    let(:output) { JSON.parse(io.string) }
    let(:logger) { SlimLint::Logger.new(io) }
    let(:report) { SlimLint::Report.new(lints, []) }
    let(:reporter) { described_class.new(logger) }

    subject { reporter.display_report(report) }

    shared_examples_for "output format specification" do
      it "matches the output specification" do
        subject
        output["metadata"]["slim_lint_version"].should_not be_empty
        output["metadata"]["ruby_engine"].should eq RUBY_ENGINE
        output["metadata"]["ruby_patchlevel"].should eq RUBY_PATCHLEVEL.to_s
        output["metadata"]["ruby_platform"].should eq RUBY_PLATFORM.to_s
        output["files"].should be_a_kind_of(Array)
        output["summary"]["offense_count"].should be_a_kind_of(Integer)
        output["summary"]["target_file_count"].should be_a_kind_of(Integer)
        output["summary"]["inspected_file_count"].should be_a_kind_of(Integer)
      end
    end

    context "when there are no lints" do
      let(:lints) { [] }
      let(:files) { [] }

      it "list of files is empty" do
        subject
        output["files"].should be_empty
      end

      it "number of target files is zero" do
        subject
        output["summary"]["target_file_count"].should eq(0)
      end

      it_behaves_like "output format specification"
    end

    context "when there are lints" do
      let(:filenames) { ["some-filename.slim", "other-filename.slim"] }
      let(:lines) { [502, 724] }
      let(:descriptions) { ["Description of lint 1", "Description of lint 2"] }
      let(:severities) { [:warning, :error] }
      let(:linters) { [double(name: "SomeLinter"), nil] }

      let(:lints) do
        filenames.each_with_index.map do |filename, index|
          location = SlimLint::SourceLocation.new(start_line: lines[index], start_column: index + 1, length: (index + 1) ** 2)
          SlimLint::Lint.new(linters[index], filename, location, descriptions[index], severities[index])
        end
      end

      it "list of files contains files with offenses" do
        subject
        output["files"].map { |f| f["path"] }.sort.should eq filenames.sort
      end

      it "list of offenses" do
        subject
        output["files"].sort_by { |f| f["path"] }.map { |f| f["offenses"] }.should eq [
          [
            {
              "cop_name" => nil,
              "location" => {
                "line" => 724,
                "column" => 2,
                "length" => 4,
                "start_line" => 724,
                "start_column" => 2,
                "last_line" => 724,
                "last_column" => 2
              },
              "message" => "Description of lint 2",
              "severity" => "error"
            }
          ],
          [
            {
              "cop_name" => "SomeLinter",
              "location" => {
                "line" => 502,
                "column" => 1,
                "length" => 1,
                "start_line" => 502,
                "start_column" => 1,
                "last_line" => 502,
                "last_column" => 1
              },
              "message" => "Description of lint 1",
              "severity" => "warning"
            }
          ]
        ]
      end

      it_behaves_like "output format specification"
    end
  end
end

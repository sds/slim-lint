# frozen_string_literal: true

require "spec_helper"

describe SlimLint::LinterSelector do
  let(:options) { {} }
  let(:config) { SlimLint::ConfigurationLoader.load_hash(config_hash) }

  let(:config_hash) do
    {
      "linters" => {
        "FakeLinter1" => {"enabled" => true},
        "FakeLinter2" => {"enabled" => true},
        "FakeLinter3" => {"enabled" => true}
      }
    }
  end

  let(:linter_selector) { described_class.new(config, options) }

  let(:fake_linter_1) do
    Class.new(SlimLint::Linter) do
      define_singleton_method(:name) { "FakeLinter1" }
      include SlimLint::LinterRegistry
    end
  end

  let(:fake_linter_2) do
    Class.new(SlimLint::Linter) do
      define_singleton_method(:name) { "FakeLinter2" }
      include SlimLint::LinterRegistry
    end
  end

  let(:fake_linter_3) do
    Class.new(SlimLint::Linter) do
      define_singleton_method(:name) { "FakeLinter3" }
      include SlimLint::LinterRegistry
    end
  end

  before do
    SlimLint::LinterRegistry
      .stub(:linters)
      .and_return([fake_linter_1, fake_linter_2, fake_linter_3])
  end

  before do
    linter_selector.stub(:extract_enabled_linters) do |config, options|
      linter_selector.send(:extract_enabled_linter_names, config, options)
    end
  end

  describe "#linters_for_file" do
    let(:file) { "some-file.slim" }
    subject { linter_selector.linters_for_file(file) }

    context "with no additional configuration or options" do
      it "returns all registered linters" do
        subject.should eq(["FakeLinter1", "FakeLinter2", "FakeLinter3"])
      end
    end

    context "when a linter is disabled in its configuration" do
      let(:config_hash) do
        {
          "linters" => {
            "FakeLinter1" => {"enabled" => true},
            "FakeLinter2" => {"enabled" => false},
            "FakeLinter3" => {"enabled" => true}
          }
        }
      end

      it "excludes the disabled linter" do
        subject.should eq(["FakeLinter1", "FakeLinter3"])
      end
    end

    context "when included_linters option was specified" do
      let(:options) { {included_linters: ["FakeLinter1"]} }

      it "returns only that linter" do
        subject.should eq(["FakeLinter1"])
      end
    end

    context "when excluded_linters option was specified" do
      let(:options) { {excluded_linters: ["FakeLinter3"]} }

      it "excludes only that linter" do
        subject.should eq(["FakeLinter1", "FakeLinter2"])
      end
    end

    context "when excluded_linters option specifies an included_linter" do
      let(:options) do
        {
          included_linters: %w[FakeLinter1 FakeLinter3],
          excluded_linters: ["FakeLinter3"]
        }
      end

      it "returns the difference of the two sets" do
        subject.should eq(["FakeLinter1"])
      end
    end

    context "when excluded_linters option specifies all included_linters" do
      let(:options) do
        {
          included_linters: %w[FakeLinter1 FakeLinter3],
          excluded_linters: %w[FakeLinter1 FakeLinter3]
        }
      end

      it "raises an error" do
        expect { subject }.to raise_error SlimLint::Exceptions::NoLintersError
      end
    end

    context "when all linters are disabled in the configuration" do
      let(:config_hash) do
        {
          "linters" => {
            "FakeLinter1" => {"enabled" => false},
            "FakeLinter2" => {"enabled" => false},
            "FakeLinter3" => {"enabled" => false}
          }
        }
      end

      it "raises an error" do
        expect { subject }.to raise_error SlimLint::Exceptions::NoLintersError
      end
    end

    context "when linter specifies `include`/`exclude` in its configuration" do
      let(:include_pattern) { [] }
      let(:exclude_pattern) { [] }

      let(:config_hash) do
        {
          "linters" => {
            "FakeLinter1" => {
              "enabled" => true,
              "include" => include_pattern,
              "exclude" => exclude_pattern
            }
          }
        }
      end

      context "and the file matches the include pattern" do
        let(:include_pattern) { "**/some-*.slim" }

        it "returns the linter" do
          subject.should eq(["FakeLinter1"])
        end
      end

      context "and the file does not match the include pattern" do
        let(:include_pattern) { "**/nope-*.slim" }

        it "excludes the linter" do
          subject.should eq([])
        end
      end

      context "and the file matches the exclude pattern" do
        let(:exclude_pattern) { "**/some-*.slim" }

        it "excludes the linter" do
          subject.should eq([])
        end
      end

      context "and the file matches the exclude pattern and the file is absolute path" do
        let(:file) { File.expand_path("some-file.slim") }
        let(:exclude_pattern) { "some-*.slim" }

        it "excludes the linter" do
          subject.should eq([])
        end
      end

      context "and the file matches both the include and exclude patterns" do
        let(:include_pattern) { "**/*-file.slim" }
        let(:exclude_pattern) { "**/some-*.slim" }

        it "excludes the linter" do
          subject.should eq([])
        end
      end
    end
  end
end

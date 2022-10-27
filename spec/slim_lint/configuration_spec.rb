# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Configuration do
  let(:config) { SlimLint::ConfigurationLoader.default_configuration }

  describe "#initialize" do
    let(:config) { described_class.new(hash) }
    subject { config }

    context "with an empty hash" do
      let(:hash) { {} }

      it "creates an empty `exclude` section" do
        subject["exclude"].should eq([])
      end

      it "creates an empty `linters` section" do
        subject["linters"].should eq({})
      end
    end

    context "with a linter with single values in its `include`/`exclude` options" do
      let(:hash) do
        {
          "linters" => {
            "SomeLinter" => {
              "include" => "**/*.slim",
              "exclude" => "**/*.ignore.slim"
            }
          }
        }
      end

      it "converts the `include` value into an array" do
        subject["linters"]["SomeLinter"]["include"].should eq(["**/*.slim"])
      end

      it "converts the `exclude` value into an array" do
        subject["linters"]["SomeLinter"]["exclude"].should eq(["**/*.ignore.slim"])
      end
    end
  end

  describe "#for_linter" do
    subject { config.for_linter(linter) }

    context "when linter is a Class" do
      let(:linter) { SlimLint::Linter::LineLength }

      it "returns the configuration for the relevant linter" do
        subject["max"].should eq(80)
      end
    end

    context "when linter is a Linter" do
      let(:linter) { SlimLint::Linter::LineLength.new(double) }

      it "returns the configuration for the relevant linter" do
        subject["max"].should eq(80)
      end
    end
  end
end

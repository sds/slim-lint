# frozen_string_literal: true

require "spec_helper"

describe SlimLint::ConfigurationLoader do
  describe ".load_applicable_config" do
    subject { described_class.load_applicable_config }

    context "when directory does not contain a configuration file" do
      around do |example|
        directory { example.run }
      end

      it "returns the default configuration" do
        subject.should eq(described_class.default_configuration)
      end
    end

    context "when directory contains a configuration file" do
      let(:config_contents) { <<-CFG }
        linters:
          ALL:
            enabled: false
      CFG

      around do |example|
        directory do
          File.write(".slim-lint.yml", config_contents)
          example.run
        end
      end

      it "loads the file" do
        described_class.should_receive(:load_file)
          .with(File.expand_path(".slim-lint.yml"))
        subject
      end

      it "merges the loaded file with the default configuration" do
        subject.should_not eq(described_class.default_configuration)
      end
    end
  end

  describe ".default_configuration" do
    subject { described_class.default_configuration }

    before do
      # Ensure cache is cleared
      described_class.instance_variable_set(:@default_configuration, nil)
    end

    it "loads the default config file" do
      described_class.should_receive(:load_from_file)
        .with(SlimLint::ConfigurationLoader::DEFAULT_CONFIG_PATH)
      subject
    end
  end

  describe ".load_file" do
    let(:file_name) { "config.yml" }
    subject { described_class.load_file(file_name) }

    around do |example|
      directory { example.run }
    end

    context "with a file that exists" do
      before do
        File.write(file_name, config_file)
      end

      context "and is empty" do
        let(:config_file) { "" }

        it "is equivalent to the default configuration" do
          subject.should eq(described_class.default_configuration)
        end
      end

      context "and is valid" do
        let(:config_file) { "skip_frontmatter: true" }

        it "loads the custom configuration" do
          subject["skip_frontmatter"].should eq(true)
        end

        it "extends the default configuration" do
          custom_config = SlimLint::Configuration.new("skip_frontmatter" => true)

          subject.should eq(described_class.default_configuration.merge(custom_config))
        end
      end

      context "and is invalid" do
        let(:config_file) { <<~CONF }
          linters:
            SomeLinter:
            invalid
        CONF

        it "raises an error" do
          expect { subject }.to raise_error SlimLint::Exceptions::ConfigurationError
        end
      end
    end

    context "with a file that does not exist" do
      it "raises an error" do
        expect { subject }.to raise_error SlimLint::Exceptions::ConfigurationError
      end
    end
  end

  describe ".load_hash" do
    subject { described_class.load_hash(hash) }

    context "when hash is empty" do
      let(:hash) { {} }

      it "is equivalent to the default configuration" do
        subject.should eq(described_class.default_configuration)
      end
    end

    context "when hash is not empty" do
      let(:hash) { {"skip_frontmatter" => true} }

      it "extends the default configuration" do
        config = described_class.default_configuration
        subject.should eq(config.merge(SlimLint::Configuration.new(hash)))
      end
    end
  end
end

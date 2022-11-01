# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Linter::RuboCop do
  let!(:rubocop_cli) { spy("rubocop_cli") }

  # Need this block before including linter context so that stubbing occurs
  # before linter is run
  before do
    ::RuboCop::CLI.stub(:new).and_return(rubocop_cli)
    SlimLint::Linter::RuboCop::OffenseCollector.stub(:offenses)
      .and_return([offence].compact)
  end

  include_context "linter"

  let(:offence) { nil }

  let(:slim) { <<-SLIM }
    span To be
    span = "or not"
    span to be
  SLIM

  it "does not specify the --config flag by default" do
    expect(rubocop_cli).to have_received(:run).with(array_excluding("--config"))
  end

  context "when RuboCop does not report offences" do
    it { should_not report_lint }
  end

  context "when RuboCop reports offences" do
    let(:line) { 4 }
    let(:column) { 1 }
    let(:message) { "Lint message" }
    let(:cop_name) { "Lint/SomeCopName" }

    let(:offence) do
      double(
        "offence",
        line: line,
        column: column,
        last_line: line,
        last_column: column,
        column_length: 1,
        message: message,
        cop_name: cop_name
      )
    end

    it "uses the source map to transform line numbers" do
      subject.should report_lint line: 2
    end

    context "and the offence is from an ignored cop" do
      let(:cop_name) { "Layout/LineLength" }
      it { should_not report_lint }
    end
  end

  context "when the SLIM_LINT_RUBOCOP_CONF environment variable is specified" do
    around do |example|
      SlimLint::Utils.with_environment "SLIM_LINT_RUBOCOP_CONF" => "some-rubocop.yml" do
        example.run
      end
    end

    it "specifies the --config flag" do
      expect(rubocop_cli)
        .to have_received(:run).with(array_including("--config", "some-rubocop.yml"))
    end
  end
end

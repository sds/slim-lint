# frozen_string_literal: true

# Makes writing tests for linters a lot DRYer by taking any `slim` variable
# defined via `let` and normalizing it and running the linter against it.
shared_context "linter" do
  let(:config) do
    SlimLint::ConfigurationLoader.default_configuration
      .for_linter(described_class)
  end

  # TODO: Run an array of lints instead of the linter
  subject { described_class.new(config) }

  before do
    document = SlimLint::Document.new(slim, config: config)
    subject.run(document)
  end
end

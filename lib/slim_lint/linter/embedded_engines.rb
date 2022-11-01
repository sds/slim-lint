# frozen_string_literal: true

module SlimLint
  # Checks for forbidden embedded engines.
  class Linter::EmbeddedEngines < Linter
    include LinterRegistry

    MESSAGE = "Forbidden embedded engine `%s` found"

    on [:slim, :embedded] do |sexp|
      _, _, engine, _ = sexp

      forbidden_engines = config["forbidden_engines"]
      next unless forbidden_engines.include?(engine)
      report_lint(sexp, MESSAGE % engine)
    end
  end
end

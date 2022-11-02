# frozen_string_literal: true

module SlimLint
  # Searches for multi-line control statements, dynamic output statements,
  # attribute values, and splats.
  class Linter::AvoidMultilineExpressions < Linter
    include LinterRegistry

    on [:slim, :control] do |sexp|
      _, _, code = sexp
      next unless code.size > 2

      msg = "Avoid control statements that span multiple lines."
      report_lint(sexp, msg)
    end

    on [:slim, :output] do |sexp|
      _, _, _, code = sexp
      next unless code.size > 2

      msg = "Avoid dynamic output statements that span multiple lines."
      report_lint(sexp, msg)
    end

    on [:slim, :attrvalue] do |sexp|
      _, _, _, code = sexp
      next unless code.size > 2

      msg = "Avoid attribute values that span multiple lines."
      report_lint(sexp, msg)
    end

    on [:slim, :splat] do |sexp|
      _, _, code = sexp
      next unless code.size > 2

      msg = "Avoid attribute values that span multiple lines."
      report_lint(sexp, msg)
    end
  end
end

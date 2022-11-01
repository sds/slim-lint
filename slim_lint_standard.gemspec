# frozen_string_literal: true

$LOAD_PATH << File.expand_path("lib", __dir__)
require "slim_lint/constants"
require "slim_lint/version"

Gem::Specification.new do |s|
  s.name = "slim_lint_standard"
  s.version = SlimLint::VERSION
  s.license = "MIT"
  s.summary = "Linter for Slim templates"
  s.description = "Configurable tool for writing clean and consistent Slim templates"
  s.authors = ["Pieter van de Bruggen", "Shane da Silva"]
  s.email = ["pvande@gmail.com", "shane@dasilva.io"]
  s.homepage = SlimLint::REPO_URL

  s.require_paths = ["lib"]

  s.executables = ["slim-lint-standard"]

  s.files = Dir["config/**.yml"] +
    Dir["lib/**/*.rb"] +
    ["LICENSE.md"]

  s.required_ruby_version = ">= 2.6.0"

  # s.add_runtime_dependency 'standard', '>= 1.16.1'
  s.add_runtime_dependency "rubocop", ">= 0.78.0"
  s.add_runtime_dependency "slim", [">= 3.0", "< 5.0"]

  s.add_development_dependency "pry", "~> 0.13"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "rspec-its", "~> 1.0"
  s.add_development_dependency "standard", ">= 1.16.1"
  s.add_development_dependency "simplecov", ">= 0.21.2"
end

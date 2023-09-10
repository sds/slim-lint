# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

# Run all pre-commit hooks via Overcommit during CI runs
gem 'overcommit', '0.60.0'

# Needed for Rake integration tests
gem 'rake'

# Pin tool versions (which are executed by Overcommit) for Travis builds
gem 'rubocop', '>= 1', '< 2'

gem 'coveralls', require: false

# On Ruby 3, rexml is only a gem
gem 'rexml' if RUBY_VERSION > '3'

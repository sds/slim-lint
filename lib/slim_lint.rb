# Load all slim-lint modules necessary to parse and lint a file.
# Ordering here can be important depending on class references in each module.

# Need to load slim before we can reference some classes or define filters
require 'slim'

require 'slim_lint/constants'
require 'slim_lint/exceptions'
require 'slim_lint/configuration'
require 'slim_lint/configuration_loader'
require 'slim_lint/utils'
require 'slim_lint/atom'
require 'slim_lint/sexp'
require 'slim_lint/file_finder'
require 'slim_lint/linter_registry'
require 'slim_lint/logger'
require 'slim_lint/version'

# Load all filters (required by SlimLint::Engine)
Dir[File.expand_path('slim_lint/filters/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end

require 'slim_lint/engine'
require 'slim_lint/document'
require 'slim_lint/capture_map'
require 'slim_lint/sexp_visitor'
require 'slim_lint/lint'
require 'slim_lint/ruby_parser'
require 'slim_lint/linter'
require 'slim_lint/reporter'
require 'slim_lint/report'
require 'slim_lint/linter_selector'
require 'slim_lint/runner'

# Load all matchers
require 'slim_lint/matcher/base'
Dir[File.expand_path('slim_lint/matcher/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end

# Load all linters
Dir[File.expand_path('slim_lint/linter/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end

# Load all reporters
Dir[File.expand_path('slim_lint/reporter/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end

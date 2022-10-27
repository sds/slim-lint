# frozen_string_literal: true

# Render coverage information in coverage/index.html and display coverage
# percentage in the console.
require "simplecov"

require "slim_lint"
require "rspec/its"

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.include DirectorySpecHelpers

  config.expect_with :rspec do |c|
    c.syntax = [:expect, :should]
  end

  config.mock_with :rspec do |c|
    c.syntax = :should
  end
end

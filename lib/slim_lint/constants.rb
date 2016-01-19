# frozen_string_literal: true

# Global application constants.
module SlimLint
  HOME = File.expand_path(File.join(File.dirname(__FILE__), '..', '..')).freeze
  APP_NAME = 'slim-lint'.freeze

  REPO_URL = 'https://github.com/sds/slim-lint'.freeze
  BUG_REPORT_URL = "#{REPO_URL}/issues".freeze
end

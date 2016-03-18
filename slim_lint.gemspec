$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'slim_lint/constants'
require 'slim_lint/version'

Gem::Specification.new do |s|
  s.name             = 'slim_lint'
  s.version          = SlimLint::VERSION
  s.license          = 'MIT'
  s.summary          = 'Slim template linting tool'
  s.description      = 'Configurable tool for writing clean and consistent Slim templates'
  s.authors          = ['Shane da Silva']
  s.email            = ['shane@dasilva.io']
  s.homepage         = SlimLint::REPO_URL

  s.require_paths    = ['lib']

  s.executables      = ['slim-lint']

  s.files            = Dir['config/**.yml'] +
                       Dir['lib/**/*.rb'] +
                       ['LICENSE.md']

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'slim', '~> 3.0'
  s.add_dependency 'rake', '>= 10', '< 12'
  s.add_dependency 'rubocop', '>= 0.36.0'
  s.add_dependency 'sysexits', '~> 1.1'

  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-its', '~> 1.0'
end

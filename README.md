# Slim-Lint

[![Gem Version](https://badge.fury.io/rb/slim_lint.svg)](http://badge.fury.io/rb/slim_lint)
[![Build Status](https://travis-ci.org/sds/slim-lint.svg)](https://travis-ci.org/sds/slim-lint)
[![Code Climate](https://codeclimate.com/github/sds/slim-lint.png)](https://codeclimate.com/github/sds/slim-lint)
[![Inline docs](http://inch-ci.org/github/sds/slim-lint.svg?branch=master)](http://inch-ci.org/github/sds/slim-lint)
[![Dependency Status](https://gemnasium.com/sds/slim-lint.svg)](https://gemnasium.com/sds/slim-lint)

`slim-lint` is a tool to help keep your [Slim](http://slim-lang.com/) files
clean and readable. In addition to style and lint checks, it integrates with
[RuboCop](https://github.com/bbatsov/rubocop) to bring its powerful static
analysis tools to your Slim templates.

You can run `slim-lint` manually from the command line, or integrate it into
your [SCM hooks](https://github.com/brigade/overcommit).

* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Configuration](#configuration)
* [Linters](#linters)
* [Git Integration](#git-integration)
* [Rake Integration](#rake-integration)
* [Documentation](#documentation)
* [Contributing](#contributing)
* [Changelog](#changelog)
* [License](#license)

## Requirements

 * Ruby 1.9.3+
 * Slim 3.0+

## Installation

```bash
gem install slim_lint
```

## Usage

Run `slim-lint` from the command line by passing in a directory (or multiple
directories) to recursively scan:

```bash
slim-lint app/views/
```

You can also specify a list of files explicitly:

```bash
slim-lint app/**/*.slim
```

`slim-lint` will output any problems with your Slim, including the offending
filename and line number.

Command Line Flag         | Description
--------------------------|----------------------------------------------------
`-c`/`--config`           | Specify which configuration file to use
`-e`/`--exclude`          | Exclude one or more files from being linted
`-i`/`--include-linter`   | Specify which linters you specifically want to run
`-x`/`--exclude-linter`   | Specify which linters you _don't_ want to run
`--[no-]color`            | Whether to output in color
`--show-linters`          | Show all registered linters
`-h`/`--help`             | Show command line flag documentation
`-v`/`--version`          | Show version

## Configuration

`slim-lint` will automatically recognize and load any file with the name
`.slim-lint.yml` as a configuration file. It loads the configuration based on
the directory `slim-lint` is being run from, ascending until a configuration
file is found. Any configuration loaded is automatically merged with the
default configuration (see [`config/default.yml`](config/default.yml)).

Here's an example configuration file:

```yaml
linters:
  LineLength:
    max: 100

  RedundantDiv:
    enabled: false
```

All linters have an `enabled` option which can be `true` or `false`, which
controls whether the linter is run, along with linter-specific options. The
defaults are defined in [`config/default.yml`](config/default.yml).

### Skipping Frontmatter

Some static blog generators such as [Jekyll](http://jekyllrb.com/) include
leading frontmatter to the template for their own tracking purposes.
`slim-lint` allows you to ignore these headers by specifying the
`skip_frontmatter` option in your `.slim-lint.yml` configuration:

```yaml
skip_frontmatter: true
```

## Linters

You can find detailed documentation on all supported linters by following the
link below:

### [» Linters Documentation](lib/slim_lint/linter/README.md)

## Git Integration

If you'd like to integrate `slim-lint` into your Git workflow, check out
[overcommit](https://github.com/brigade/overcommit), a powerful and flexible
Git hook manager.

## Rake Integration

To execute `slim-lint` via a [Rake](https://github.com/ruby/rake) task, add the
following to your `Rakefile`:

```ruby
require 'slim_lint/rake_task'

SlimLint::RakeTask.new
```

By default, when you execute `rake slim_lint`, the above configuration is
equivalent to running `slim-lint .`, which will lint all `.slim` files in the
current directory and its descendants.

You can customize your task by writing:

```ruby
require 'slim_lint/rake_task'

SlimLint::RakeTask.new do |t|
  t.config = 'custom/config.yml'
  t.files = ['app/views', 'custom/*.slim']
  t.quiet = true # Don't display output from slim-lint to STDOUT
end
```

You can also use this custom configuration with a set of files specified via
the command line:

```
# Single quotes prevent shell glob expansion
rake 'slim_lint[app/views, custom/*.slim]'
```

Files specified in this manner take precedence over the task's `files`
attribute.

## Documentation

[Code documentation] is generated with [YARD] and hosted by [RubyDoc.info].

[Code documentation]: http://rdoc.info/github/sds/slim-lint/master/frames
[YARD]: http://yardoc.org/
[RubyDoc.info]: http://rdoc.info/

## Contributing

We love getting feedback with or without pull requests. If you do add a new
feature, please add tests so that we can avoid breaking it in the future.

Speaking of tests, we use `rspec`, which can be run by executing the following
from the root directory of the repository:

```bash
bundle exec rspec
```

## Changelog

If you're interested in seeing the changes and bug fixes between each version
of `slim-lint`, read the [Slim-Lint Changelog](CHANGELOG.md).

## License

This project is released under the [MIT license](MIT-LICENSE).

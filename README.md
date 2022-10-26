# `slim-lint-standard`

[![Gem Version](https://badge.fury.io/rb/slim_lint_standard.svg)](http://badge.fury.io/rb/slim_lint_standard)
[![Code Climate](https://codeclimate.com/github/pvande/slim-lint-standard.svg)](https://codeclimate.com/github/pvande/slim-lint-standard)

`slim-lint-standard` is a tool to help keep your [Slim](http://slim-lang.com/) files
clean and readable. In addition to style and lint checks, it integrates with
[RuboCop](https://github.com/bbatsov/rubocop) to bring its powerful static
analysis tools to your Slim templates.

You can run `slim-lint-standard` manually from the command line, or integrate it into
your [SCM hooks](https://github.com/brigade/overcommit).

* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Configuration](#configuration)
* [Linters](#linters)
* [Editor Integration](#editor-integration)
* [Git Integration](#git-integration)
* [Rake Integration](#rake-integration)
* [Documentation](#documentation)
* [Contributing](#contributing)
* [Changelog](#changelog)
* [License](#license)

## Requirements

 * Ruby 2.6+
 * Slim 3.0+

## Installation

```bash
gem install slim_lint_standard
```

## Usage

Run `slim-lint-standard` from the command line by passing in a directory (or multiple
directories) to recursively scan:

```bash
slim-lint-standard app/views/
```

You can also specify a list of files explicitly:

```bash
slim-lint-standard app/**/*.slim
```

`slim-lint-standard` will output any problems with your Slim, including the offending
filename and line number.

Command Line Flag         | Description
--------------------------|----------------------------------------------------
`-c`/`--config`           | Specify which configuration file to use
`-e`/`--exclude`          | Exclude one or more files from being linted
`-i`/`--include-linter`   | Specify which linters you specifically want to run
`-x`/`--exclude-linter`   | Specify which linters you _don't_ want to run
`--stdin-file-path [file]`| Pipe source from STDIN, using file in offense reports
`--[no-]color`            | Whether to output in color
`--reporter [reporter]`   | Specify which output formatter to use
`--show-linters`          | Show all registered linters
`--show-reporters`        | Show all available reporters
`-h`/`--help`             | Show command line flag documentation
`-v`/`--version`          | Show version
`-V`/`--verbose-version`  | Show detailed version information

## Configuration

`slim-lint-standard` will automatically recognize and load any file with the name
`.slim-lint.yml` as a configuration file. It loads the configuration based on
the directory `slim-lint-standard` is being run from, ascending until a configuration
file is found. Any configuration loaded is automatically merged with the
default configuration (see [`config/default.yml`](config/default.yml)).

Here's an example configuration file:

```yaml
exclude:
  - 'exclude/files/in/this/directory/from/all/linters/**/*.slim'

linters:
  EmptyControlStatement:
    exclude:
      - 'app/views/directory_of_files_to_exclude/**/*.slim'
      - 'specific/file/to/exclude.slim'

  LineLength:
    include: 'specific/directory/to/include/**/*.slim'
    max: 100

  RedundantDiv:
    enabled: false
```

All linters have an `enabled` option which can be `true` or `false`, which
controls whether the linter is run, along with linter-specific options. The
defaults are defined in [`config/default.yml`](config/default.yml).

### Linter Options

Option        | Description
--------------|----------------------------------------------------------------
`enabled`     | If `false`, this linter will never be run. This takes precedence over any other option.
`include`     | List of files or glob patterns to scope this linter to. This narrows down any files specified via the command line.
`exclude`     | List of files or glob patterns to exclude from this linter. This excludes any files specified via the command line or already filtered via the `include` option.

### Global File Exclusion

The `exclude` global configuration option allows you to specify a list of files
or glob patterns to exclude from all linters. This is useful for ignoring
third-party code that you don't maintain or care to lint. You can specify a
single string or a list of strings for this option.

### Skipping Frontmatter

Some static blog generators such as [Jekyll](http://jekyllrb.com/) include
leading frontmatter to the template for their own tracking purposes.
`slim-lint-standard` allows you to ignore these headers by specifying the
`skip_frontmatter` option in your `.slim-lint.yml` configuration:

```yaml
skip_frontmatter: true
```

### Disabling Linters For Specific Code

#### `slim-lint-standard` linters

To disable a linter, you can use a slim comment:
```slim
/ slim-lint:disable TagCase
IMG src="images/cat.gif"
/ slim-lint:enable TagCase
```

### Rubocop cops
To disable Rubocop cop, you can use a coment control statement:
```slim
- # rubocop:disable Rails/OutputSafety
p = raw(@blog.content)
- # rubocop:enable Rails/OutputSafety
```
## Linters

You can find detailed documentation on all supported linters by following the
link below:

### [» Linters Documentation](lib/slim_lint/linter/README.md)

## Documentation

[Code documentation] is generated with [YARD] and hosted by [RubyDoc.info].

[Code documentation]: http://rdoc.info/github/pvande/slim-lint-standard/master/frames
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
of `slim-lint-standard`, read the [Changelog](CHANGELOG.md).

## License

This project is released under the [MIT license](LICENSE.md).

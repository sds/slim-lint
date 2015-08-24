# Slim-Lint Changelog

## 0.6.1

* Fix `exclude` option to work with paths prefixed with `./`

## 0.6.0

* Change required Ruby version from 1.9.3+ to 2.0.0+
* Fix rake task integration to not crash when running `rake -T`
* Improve bug reporting instructions in error message
* Add `-V/--verbose-version` flag to display `slim`, `rubocop`, and `ruby`
  version information in addition to output of `-v/--version` flag

## 0.5.0

* Add support for `SLIM_LINT_RUBOCOP_CONF` environment variable to `RuboCop`
  linter, allowing external tools to specify RuboCop configuration to use
* Change required Ruby version from 2.0.0+ to 1.9.3+
* Remove cop name from RuboCop offense message (this can be added via the
  `DisplayCopNames` option in your `.rubocop.yml`)

## 0.4.0

* Fix Ruby code extraction to result in fewer false positives from `RuboCop`
* Fix `ConsecutiveControlStatements` to not report control statements with
  nested content (i.e. `if`/`elsif`/`else`)

## 0.3.0

* Add support for `include`/`exclude` options on linters, allowing a list of
  files or glob patterns to be included/excluded from a linter's scope
* Add support for global `exclude` configuration option allowing a list of
  files or glob patterns to be excluded from all linters

## 0.2.0

* Ignore `Style/IndentationConsistency` RuboCop warnings
* Add `ConsecutiveControlStatements` which recommends condensing multiple
  control statements into a single `ruby:` filter
* Add `EmptyControlStatement` which reports control statements with no code
* Add `CommentControlStatement` which reports control statement with only
  comments
* Add `TagCase` which reports tags with uppercase characters

## 0.1.0

* Initial release

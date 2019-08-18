# Slim-Lint Changelog

## 0.17.1

* Fix `CommentControlStatement` to not report `rubocop:{enable,disable}` directives

## 0.17.0

* Disable `Layout/AlignArguments` and `Layout/InitialIndentation` cops by default
* Update `EmptyLineAfterGuardClause` cop namespace from `Style` to `Layout` to fix errors
* Drop support for Ruby 2.3 and older

## 0.16.1

* Fix `ControlStatementSpacing` to support other output operators `=>`, `=<>`,
  and `=<`

## 0.16.0

* Add `ControlStatementSpacing` linter
* Allow Slim 4.x

## 0.15.1

* Fix `TrailingBlankLines` to ignore empty files
* Fix `excludes` option to correctly filter files when relative path globs
  are used

## 0.15.0

* Improve RuboCop linter to not use temporary files when linting

## 0.14.0

* Add `TrailingBlankLines` linter
* Add `EmptyLines` linter
* Add support for RuboCop 0.50.0
* Require RuboCop 0.50.0 or newer
* Fix `Metrics/BlockNesting` RuboCop cop to be disabled by default
* Disable `Layout/AlignArray` and `Layout/IndentArray` RuboCop cops by default

## 0.13.0

* Add support for RuboCop 0.49.0
* Require RuboCop 0.49.0 or newer

## 0.12.0

* Add support for RuboCop 0.48.0
* Require RuboCop 0.48.0 or newer

## 0.11.0

* Update minimum RuboCop version to 0.47.0+ due to [breaking change in
  RuboCop AST interface](https://github.com/bbatsov/rubocop/commit/48f1637eb36)

## 0.10.0

* Relax rake gem constraint to allow 12.x

## 0.9.0

* Fix `skip_frontmatter` option
* Add `Tab` linter which reports the use of hard tabs as indentation

## 0.8.3

* Disable `Style/Multiline*` cops by default
* Disable `Metrics/BlockLength` RuboCop cop by default

## 0.8.2

* Additional fix for line numbers reported when Ruby code spans multiple
  lines in a single control/code statement

## 0.8.1

* Fix line numbers reported when Ruby code spans multiple lines in a single
  control/code statement

## 0.8.0

* Add `Checkstyle` reporter

## 0.7.2

* Relax `rake` gem dependency to allow rake 11.x.x

## 0.7.1

* Fix `RuboCop` linter to not report `FrozenStringLiteralComment` cops
  as these are noisy in Slim templates

## 0.7.0

* Fix compatibility issues with Astrolabe gem by updating minimum RuboCop
  version to 0.36.0
* Fix `RuboCop` linter to not erroneously report
  `Style/IdenticalConditionalBranches` warnings

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

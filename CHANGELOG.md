# Slim-Lint Changelog

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

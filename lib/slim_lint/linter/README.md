# Linters

Below is a list of linters supported by `slim-lint`, ordered alphabetically.

* [CommentControlStatement](#commentcontrolstatement)
* [ConsecutiveControlStatements](#consecutivecontrolstatements)
* [EmptyControlStatement](#emptycontrolstatement)
* [FileLength](#filelength)
* [LineLength](#linelength)
* [RedundantDiv](#redundantdiv)
* [RuboCop](#rubocop)
* [Tab](#tab)
* [TagCase](#tagcase)
* [TrailingWhitespace](#trailingwhitespace)

## CommentControlStatement

Reports control statements with only comments.

**Bad**
```slim
-# This is a control statement comment
```

**Good**
```slim
/ This is a Slim comment
```

Slim comments should be preferred as they do not result in any generated Ruby
code and are optimized out of the parse tree during compilation.

## ConsecutiveControlStatements

Option             | Description
-------------------|-----------------------------------------------------
`max_consecutive`  | Maximum number of control statements that can appear in a row

Reports the appearance of multiple consecutive control statements.

**Bad**
```slim
- some_code
- some_more_code
- do_you_really_need_this_much_code?
```

**Better**
```slim
ruby:
  some_code
  some_more_code
  do_you_really_need_this_much_code?
```

**Best**
```slim
- helper_that_does_all_of_the_above
```

Large blocks of code in templates make them difficult to read and are usually
a smell. It is best to extract these into separate helpers whenever possible.

## EmptyControlStatement

Reports control statements with no code.

**Bad**
```slim
p Something
-
p Something else
```

**Good**
```slim
p Something
p Something else
```

## FileLength

Option | Description
-------|-----------------------------------------------------------------
`max`  | Maximum number of lines a single file can have. (default `300`)

You can configure this amount via the `max`
option on the linter, e.g. by adding the following to your `.slim-lint.yml`:

```yaml
linters:
  FileLength:
    max: 100
```

Long files are harder to read and usually indicative of complexity.

## LineLength

Option | Description
-------|-----------------------------------------------------------------
`max`  | Maximum number of columns a single line can have. (default `80`)

Wrap lines at 80 characters. You can configure this amount via the `max`
option on the linter, e.g. by adding the following to your `.slim-lint.yml`:

```yaml
linters:
  LineLength:
    max: 100
```

Long lines are harder to read and usually indicative of complexity.

## RedundantDiv

Reports explicit uses of `div` when it would otherwise be implicit.

**Bad: `div` is unnecessary when class/ID is specified**
```slim
div.button
```

**Good: `div` is required when no class/ID is specified**
```slim
div
```

**Good**
```slim
.button
```

Slim was designed to be concise, and not embracing this makes the tool less
useful.

## RuboCop

Option         | Description
---------------|--------------------------------------------
`ignored_cops` | Array of RuboCop cops to ignore.

This linter integrates with [RuboCop](https://github.com/bbatsov/rubocop) (a
static code analyzer and style enforcer) to check the actual Ruby code in your
templates. It will respect any RuboCop-specific configuration you have set in
`.rubocop.yml` files, but will explicitly ignore some checks (like
`Style/IndentationWidth`) since the extracted Ruby code sent to RuboCop is not
well-formatted.

```slim
- name = 'James Brown'
- unused_variable = 42

p Hello #{name}!
```

**Output from `slim-lint`**
```
example.slim:2 [W] Useless assignment to variable - unused_variable
```

You can customize which RuboCop warnings you want to ignore by modifying
the `ignored_cops` option (see [`config/default.yml`](/config/default.yml)
for the full list of ignored cops). Note that if you modify the list you'll
need to re-include all the items from the default configuration.

You can also explicitly set which RuboCop configuration to use via the
`SLIM_LINT_RUBOCOP_CONF` environment variable. This is intended to be used
by external tools which run the linter on files in temporary directories
separate from the directory where the Slim template originally resided (and
thus where the normal `.rubocop.yml` would be picked up).

### Displaying Cop Names

You can display the name of the cop by adding the following to your
`.rubocop.yml` configuration:

```yaml
AllCops:
  DisplayCopNames: true
```

## Tab

Reports detection of tabs used for indentation.

## TagCase

Reports tag names with uppercase characters.

**Bad**
```slim
BODY
  P My paragraph
```

**Good**
```slim
body
  p My paragraph
```

While the HTML standard does not require lowercase tag names, they are a
_de facto_ standard and are used in almost all documentation and specifications
available online. However, lowercase tags are required for XHTML documents, so
using them consistently results in more portable code.

## TrailingWhitespace

Reports trailing whitespace (spaces or tabs) on any lines in a Slim document.

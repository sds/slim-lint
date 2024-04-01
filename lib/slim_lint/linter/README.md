# Linters

Below is a list of linters supported by `slim-lint`, ordered alphabetically.

* [CommentControlStatement](#commentcontrolstatement)
* [ConsecutiveControlStatements](#consecutivecontrolstatements)
* [ControlStatementSpacing](#controlstatementspacing)
* [EmbeddedEngines](#embeddedengines)
* [EmptyControlStatement](#emptycontrolstatement)
* [EmptyLines](#emptylines)
* [FileLength](#filelength)
* [InstanceVariables](#instancevariables)
* [LineLength](#linelength)
* [RedundantDiv](#redundantdiv)
* [RuboCop](#rubocop)
* [StrictLocalsMissing](#strictlocalsmissing)
* [Tab](#tab)
* [TagCase](#tagcase)
* [TrailingBlankLines](#trailingblanklines)
* [TrailingWhitespace](#trailingwhitespace)
* [Zwsp](#zwsp)

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

## ControlStatementSpacing

Reports missing or superfluous spacing before and after control statements

**Bad**
```slim
div= some_code
```

**Good**
```slim
div = some_code
```

## EmbeddedEngines

Reports forbidden [embedded engines](https://github.com/slim-template/slim#embedded-engines-markdown-) if listed.

Option | Description
-------|-----------------------------------------------------------------
`forbidden_engines`  | List of forbidden embedded engines. (default [])

```yaml
linters:
  EmbeddedEngines:
    enabled: true
    forbidden_engines:
      - javascript
```

**Bad for above configuration**
```slim
p Something

javascript:
  alert('foo')
```

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

## EmptyLines

Reports two or more consecutive blank lines.

**Bad**
```slim
p Something


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

## InstanceVariables

Reports instance variables in Slim templates. Use the `include` configuration
option to narrow down the files to e.g. only partial view templates in Rails:


```yaml
linters:
  InstanceVariables:
    enabled: true
    include:
      - app/views/**/_*.html.slim
```

**Bad for the above configuration**

In `app/views/somewhere/_partial.html.slim`:

```slim
= @hello
```
**Good for the above configuration**

In `app/views/somewhere/show.html.slim`:

```slim
= render 'partial', hello: @hello
```
In `app/views/somewhere/_partial.html.slim`:

```slim
= hello
```

The linter allows ensuring only local variables and/or helper methods are used
in the configured set of Slim templates. This is often encouraged in Rails
partial templates.

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

## StrictLocalsMissing

Reports on missing [strict locals magic comment](https://guides.rubyonrails.org/action_view_overview.html#strict-locals)
in Slim templates. Use the `include` configuration option to narrow down
the files to e.g. only partial view templates in Rails:

```yaml
linters:
  StrictLocalsMissing:
    enabled: true
    include:
      - app/views/**/_*.html.slim
```

**Bad for the above configuration**

In `app/views/somewhere/_partial.html.slim`:

```slim
= some_helper(foo, bar)
```
**Good for the above configuration**

In `app/views/somewhere/_partial.html.slim`:

```slim
/# locals: (foo:, bar: 'default')
= some_helper(foo, bar)
```

By default, Rails partial templates accept any local variables.
Strict locals, on the other hand, help define an explicit interface
for the template that shows which local variables it accepts.

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

## TrailingBlankLines

Reports trailing blank lines.

## TrailingWhitespace

Reports trailing whitespace (spaces or tabs) on any lines in a Slim document.

## Zwsp

Reports it contains ZWSP(zero width space).

**Bad**

```slim
| Hello Zwsp\u200b
```

**Good**

```slim
| Hello without zwsp
```

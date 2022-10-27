# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Parser do
  context "has parity with the Slim::Parser" do
    context "for line indicators" do
      context "like `|`" do
        specify "when text blocks starts with the `|` as line indicator" do
          should parse_identically(<<~'SLIM')
            | Text block
          SLIM
        end

        specify "multiple lines can be indented beneath the first text line" do
          should parse_identically(<<~'SLIM')
            |  Text
                block

                with

                multiple
              lines
          SLIM
        end

        specify "the first line of a text block determines the indentation" do
          should parse_identically(<<~'SLIM')
            |

              Text
                block

                with

                multiple
              lines
          SLIM
        end

        specify "you can nest text blocks beneath tags" do
          should parse_identically(<<~'SLIM')
            body
              | Text
          SLIM
        end

        specify "you can embed HTML code in the text which is not escaped" do
          should parse_identically(<<~'SLIM')
            | <a href="http://slim-lang.com">slim-lang.com</a>
          SLIM
        end
      end

      context "like `'`" do
        specify "text blocks with trailing white space starts with the `'` as line indicator" do
          should parse_identically(<<~'SLIM')
            ' Text block
          SLIM
        end

        specify "this is especially useful if you use tags behind a text block" do
          should parse_identically(<<~'SLIM')
            ' Link to
            a href="http://slim-lang.com" slim-lang.com
          SLIM
        end

        specify "multiple lines can be indented beneath the first text line" do
          should parse_identically(<<~'SLIM')
            '  Text
                block

                with

                multiple
              lines
          SLIM
        end

        specify "the first line of a text block determines the indentation" do
          should parse_identically(<<~'SLIM')
            '

              Text
                block

                with

                multiple
              lines
          SLIM
        end
      end

      context "like `<`" do
        specify "HTML can be written directly" do
          should parse_identically(<<~'SLIM')
            <a href="http://slim-lang.com">slim-lang.com</a>
          SLIM
        end

        specify "HTML tags allow nested blocks inside" do
          should parse_identically(<<~'SLIM')
            <html>
              <head>
                title Example
              </head>
              body
                - if true
                  | yes
                - else
                  | no
            </html>
          SLIM
        end
      end

      context "like `-`" do
        specify "the dash `-` denotes arbitrary control code" do
          should parse_identically(<<~'SLIM')
            - greeting = 'Hello, World!'
            - if false
              | Not true
            - else
              = greeting
          SLIM
        end

        specify "complex code can be broken with backslash `\\`" do
          # This doesn't parse identically, because we deliberately retain
          # indentation for multiline control statements.
          should parse_identically_accounting_for_whitespace(<<~'SLIM')
            - greeting = 'Hello, '+\
                \
                'World!'
            - if false
              | Not true
            - else
              = greeting
          SLIM
        end

        specify "you can also write loops like this" do
          should parse_identically(<<~'SLIM')
            - items = [{name: 'table', price: 10}, {name: 'chair', price: 5}]
            table#items
              - for item in items do
                tr
                  td.name = item[:name]
                  td.price = item[:price]
          SLIM
        end

        specify "the `do` keyword can be omitted" do
          should parse_identically(<<~'SLIM')
            - items = [{name: 'table', price: 10}, {name: 'chair', price: 5}]
            table#items
              - for item in items
                tr
                  td.name = item[:name]
                  td.price = item[:price]
          SLIM
        end
      end

      context "like `=`" do
        specify "the equal sign `=` produces dynamic output" do
          should parse_identically(<<~'SLIM')
            = 7*7
          SLIM
        end

        specify "dynamic output is escaped by default" do
          should parse_identically(<<~'SLIM')
            = '<script>evil();</script>'
          SLIM
        end

        specify "long code lines can be broken with `\\`" do
          should parse_identically(<<~'SLIM')
            = (0..10).map do |i|\
              2**i \
              end.join(', ')
          SLIM
        end

        specify "you don't need the explicit `\\` if the line ends with a comma `,`" do
          should parse_identically(<<~'SLIM')
            ruby:
              def self.test(*args)
                args.join('-')
              end
            = test('arg1',
              'arg2',
              'arg3')
          SLIM
        end

        specify "the equal sign with modifier `=>` produces dynamic output with a trailing white space" do
          should parse_identically(<<~'SLIM')
            => 7*7
          SLIM
        end

        specify "the equal sign with modifier `=<` produces dynamic output with a leading white space" do
          should parse_identically(<<~'SLIM')
            =< 7*7
          SLIM
        end

        specify "the equal sign with modifiers `=<>` produces dynamic output with a leading and trailing white space" do
          should parse_identically(<<~'SLIM')
            =<> 7*7
          SLIM
        end
      end

      context "like `==`" do
        specify "double equal sign `==` produces dynamic output without HTML escaping" do
          should parse_identically(<<~'SLIM')
            == '<script>evil();</script>'
          SLIM
        end

        specify "the equal sign with modifier `=>` produces dynamic output with a trailing white space" do
          should parse_identically(<<~'SLIM')
            ==> 7*7
          SLIM
        end

        specify "the equal sign with modifier `=<` produces dynamic output with a leading white space" do
          should parse_identically(<<~'SLIM')
            ==< 7*7
          SLIM
        end

        specify "the equal sign with modifiers `=<>` produces dynamic output with a leading and trailing white space" do
          should parse_identically(<<~'SLIM')
            ==<> 7*7
          SLIM
        end
      end

      context "like `/`" do
        specify "code comments begin with `/` and produce no output" do
          should parse_identically(<<~'SLIM')
            / Comment
            body
              / Another comment
                with

                multiple lines
              p Hello!
          SLIM
        end
      end

      context "like `/!`" do
        specify "HTML comments begin with `/!`" do
          should parse_identically(<<~'SLIM')
            /! Comment
            body
              /! Another comment
                with multiple lines
              p Hello!
              /!
                  First line determines indentation

                  of the comment
          SLIM
        end
      end

      context "like `/[...]`" do
        specify "conditional comments begin with `/[...]`" do
          should parse_identically(<<~'SLIM')
            /[if IE]
                p Get a better browser.
          SLIM
        end
      end
    end

    context "for HTML tags" do
      context "like doctype tags" do
        specify "you can output the XML version using the doctype tag" do
          should parse_identically(<<~'SLIM')
            doctype xml
            doctype xml ISO-8859-1
          SLIM
        end

        specify "in XHTML mode the following doctypes are supported" do
          should parse_identically(<<~'SLIM')
            doctype html
            doctype 5
            doctype 1.1
            doctype strict
            doctype frameset
            doctype mobile
            doctype basic
            doctype transitional
          SLIM
        end
      end

      context "like closed tags" do
        specify "you can close tags explicitly by appending a trailing `/`" do
          should parse_identically(<<~'SLIM')
            div id="not-closed"
            .closed/
            #closed/
            div id="closed"/
          SLIM
        end

        specify "standard html tags (img, br, ...) are closed automatically" do
          should parse_identically(<<~'SLIM')
            img src="image.png"
          SLIM
        end
      end

      context "like trailing and leading whitespace" do
        specify "you can force a trailing whitespace behind a tag by adding `>`" do
          should parse_identically(<<~'SLIM')
            a#closed> class="test" /
            a#closed> class="test"/
            a> href='url1' Link1
            a< href='url1' Link1
          SLIM
        end

        specify "only one trailing whitespace is added if you combine `>` and `=>`" do
          should parse_identically(<<~'SLIM')
            a> => 'Text1'
            a => 'Text2'
            a> = 'Text3'
            a>= 'Text4'
            a=> 'Text5'
            a<= 'Text6'
            a=< 'Text7'
          SLIM
        end

        specify "you can force a leading whitespace before a tag by adding `<`" do
          should parse_identically(<<~'SLIM')
            a#closed< class="test" /
            a#closed< class="test"/
            a< href='url1' Link1
            a< href='url2' Link2
          SLIM
        end

        specify "you can also combine `<` and `>`" do
          should parse_identically(<<~'SLIM')
            a#closed<> class="test" /
            a#closed>< class="test"/
            a<> href='url1' Link1
            a<> href='url2' Link2
          SLIM
        end
      end

      context "like inline tags" do
        specify "you may want to be a little more compact and inline the tags" do
          should parse_identically(<<~'SLIM')
            ul
              li.first: a href="/first" First
              li: a href="/second" Second
          SLIM
        end

        specify "you can wrap the attributes for readability" do
          should parse_identically(<<~'SLIM')
            ul
              li.first: a(href="/first") First
              li: a(href="/second") Second
              li
                a(href="http://slim-lang.com" class="important") Link
              li
                a[href="http://slim-lang.com" class="important"] Link
              li
                a{href="http://slim-lang.com" class="important"} Link
          SLIM
        end

        specify "wrapped attributes can span lines" do
          should parse_identically(<<~'SLIM')
            a(href="http://slim-lang.com"

                class="important") Link

            dl(
              itemprop='address'
              itemscope
              itemtype='http://schema.org/PostalAddress'
            )
          SLIM
        end

        specify "attribute wrappers and assignment may use spaces around them" do
          should parse_identically(<<~'SLIM')
            h1 id = "logo" Logo
            h2 [ id = "tagline" ] Tagline
          SLIM
        end

        specify "you can use single or double quotes for simple text attributes" do
          should parse_identically(<<~'SLIM')
            a href="http://slim-lang.com" title='Slim Homepage' Goto the Slim homepage
          SLIM
        end

        specify "you can use text interpolation in the quoted attributes" do
          should parse_identically(<<~'SLIM')
            - url='slim-lang.com'
            a href="http://#{url}" Goto the #{url}
            a href="{"test"}" Test of quoted text in braces
          SLIM
        end

        specify "attribute values will be escaped by default" do
          should parse_identically(<<~'SLIM')
            li
              a href='&' Link
          SLIM
        end

        specify "use `==` if you want to disable attribute escaping" do
          should parse_identically(<<~'SLIM')
            li
              a href=='&amp;' Link
          SLIM
        end

        specify "you can use newlines in quoted attributes" do
          should parse_identically(<<~'SLIM')
            a data-title="help" data-content="extremely long help text that goes on
              and on and on and then starts over...." Link
          SLIM
        end

        specify "you can use a backslash before a newline in quoted attributes" do
          should parse_identically(<<~'SLIM')
            a data-title="help" data-content="extremely long help text that goes on\
              and on and on and then starts over...." Link
          SLIM
        end

        specify "long Ruby attributes can be broken across lines with a backslash" do
          should parse_identically(<<~'SLIM')
            a href=1+\
              1 Link
          SLIM
        end

        specify "long Ruby attributes can be broken across lines if the line ends with a comma" do
          should parse_identically(<<~'SLIM')
            ruby:
              def self.test(*args)
                args.join('-')
              end
            a href=test('arg1',
            'arg2',
            'arg3') Link
          SLIM
        end

        specify "attribute values `true`, `false` and `nil` are interpreted as booleans" do
          should parse_identically(<<~'SLIM')
            - true_value1 = ""
            - true_value2 = true
            input type="text" disabled=true_value1
            input type="text" disabled=true_value2
            input type="text" disabled="disabled"
            input type="text" disabled=true

            - false_value1 = false
            - false_value2 = nil
            input type="text" disabled=false_value1
            input type="text" disabled=false_value2
            input type="text"
            input type="text" disabled=false
            input type="text" disabled=nil
          SLIM
        end

        specify "boolean attribute values can omit the assignment if they are wrapped" do
          should parse_identically(<<~'SLIM')
            input(type="text" disabled)
          SLIM
        end

        specify "some attributes can be automatically merged" do
          should parse_identically(<<~'SLIM')
            a.menu class="highlight" href="http://slim-lang.com/" Slim-lang.com
          SLIM
        end

        specify "arrays are automatically merged as well" do
          should parse_identically(<<~'SLIM')
            - classes = [:alpha, :beta]
            span class=["first","highlight"] class=classes First
            span class=:second,:highlight class=classes Second
          SLIM
        end

        specify "dynamic tags can be created using an attribute splat" do
          should parse_identically(<<~'SLIM')
            ruby:
              def self.a_unless_current
                @page_current ? {tag: 'span'} : {tag: 'a', href: 'http://slim-lang.com/'}
              end
            - @page_current = true
            *a_unless_current Link
            - @page_current = false
            *a_unless_current Link
          SLIM
        end
      end

      context "with shorthand" do
        specify "ID and class shorthand can contain dashes, slashes with digits, and colons" do
          should parse_identically(<<~'SLIM')
            .-test text
            #test- text
            .--a#b- text
            .a--test-123#--b text
            .a-1/2#b-1/2 text
            .ab:c-test#d:e text
          SLIM
        end
      end
    end

    context "with interpolation" do
      specify "tags can use standard Ruby interpolation" do
        should parse_identically(<<~'SLIM')
          - user="John Doe <john@doe.net>"
          h1 Welcome #{user}!
        SLIM
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Parser do
  context "differences from the original parser include" do
    context "1) `:newline` tokens are omitted" do
      let(:template) { <<~'SLIM' }
        p.one
        p.two
      SLIM

      # This parse tree includes `:newline` tokens to aid in the construction of
      # useful stacktraces during template evaluation. These are unfortunately
      # neither accurate nor detailed enough for our needs.
      it do
        should officially_parse_as [
          :multi,
          [
            :html, :tag, "p",
            [
              :html, :attrs,
              [:html, :attr, "class", [:static, "one"]]
            ],
            [:multi, [:newline]]
          ],
          [
            :html, :tag, "p",
            [
              :html, :attrs,
              [:html, :attr, "class", [:static, "two"]]
            ],
            [:multi, [:newline]]
          ]
        ]
      end

      # Since they are otherwise noise in our process, it does not make sense
      # for us to retain the population of these `:newline` tokens (especially
      # since we are capturing the relevant data in other ways).
      it do
        should parse_as [
          :multi,
          [
            :html, :tag, "p",
            [
              :html, :attrs,
              [:html, :attr, "class", [:static, "one"]]
            ],
            [:multi]
          ],
          [
            :html, :tag, "p",
            [
              :html, :attrs,
              [:html, :attr, "class", [:static, "two"]]
            ],
            [:multi]
          ]
        ]
      end
    end

    context "2) control code is captured as a `:multi`, not a String" do
      let(:template) { <<~'SLIM' }
        - variable = value
        - multiline = call 1,
            2,
            3
      SLIM

      # This parse tree doesn't include enough information about indentation,
      # which prevents certain linters and makes column information for
      # subsequent lines impossible to calculate.
      it do
        should officially_parse_as [
          :multi,
          [:slim, :control, "variable = value", [:multi, [:newline]]],
          [:slim, :control, "multiline = call 1,\n2,\n3", [:multi, [:newline]]]
        ]
      end

      # To resolve the issues with the original parse tree, we capture each
      # line as its own expression, including leading whitespace, and group
      # them into a `:multi` expression.
      it do
        should parse_as [
          :multi,
          [
            :slim, :control,
            [:multi, [:code, "variable = value"]],
            [:multi]
          ],
          [
            :slim, :control,
            [
              :multi,
              [:code, "multiline = call 1,"],
              [:code, "  2,"],
              [:code, "  3"]
            ],
            [:multi]
          ]
        ]
      end
    end

    context "3) output code is captured as a `:multi`, not a String" do
      let(:template) { <<~'SLIM' }
        = value
        = call 1,
            2,
            3
      SLIM

      # This parse tree doesn't include enough information about indentation,
      # which prevents certain linters and makes column information for
      # subsequent lines impossible to calculate.
      it do
        should officially_parse_as [
          :multi,
          [:slim, :output, true, "value", [:multi, [:newline]]],
          [:slim, :output, true, "call 1,\n2,\n3", [:multi, [:newline]]]
        ]
      end

      # To resolve the issues with the original parse tree, we capture each
      # line as its own expression, including leading whitespace, and group
      # them into a `:multi` expression.
      it do
        should parse_as [
          :multi,
          [
            :slim, :output, true,
            [:multi, [:code, "value"]],
            [:multi]
          ],
          [
            :slim, :output, true,
            [
              :multi,
              [:code, "call 1,"],
              [:code, "  2,"],
              [:code, "  3"]
            ],
            [:multi]
          ]
        ]
      end
    end

    context "4) attribute values and splats are captured as a `:multi`, not a String" do
      let(:template) { <<~'SLIM' }
        tag attr="value" Content
        tag attr=variable Content
        tag attr=call(1,
            2,
            3) Content
        tag attr=call(1,
                      2,
                      3) Content
        tag attr=call(1,
                      2,
                      3) attr-two=call(1,
                                       2) Content
      SLIM

      # This parse tree doesn't include enough information about indentation,
      # which prevents certain linters and makes column information for
      # subsequent lines impossible to calculate.
      it do
        should officially_parse_as [
          :multi,
          [
            :html, :tag, "tag",
            [
              :html, :attrs,
              [:html, :attr, "attr", [:escape, true, [:slim, :interpolate, "value"]]]
            ],
            [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Content"]]]
          ],
          [:newline],
          [
            :html, :tag, "tag",
            [
              :html, :attrs,
              [:html, :attr, "attr", [:slim, :attrvalue, true, "variable"]]
            ],
            [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Content"]]]
          ],
          [:newline],
          [
            :html, :tag, "tag",
            [
              :html, :attrs,
              [:html, :attr, "attr", [:slim, :attrvalue, true, "call(1,\n2,\n3)"]]
            ],
            [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Content"]]]
          ],
          [:newline],
          [
            :html, :tag, "tag",
            [
              :html, :attrs,
              [:html, :attr, "attr", [:slim, :attrvalue, true, "call(1,\n2,\n3)"]]
            ],
            [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Content"]]]
          ],
          [:newline],
          [
            :html, :tag, "tag",
            [
              :html, :attrs,
              [:html, :attr, "attr", [:slim, :attrvalue, true, "call(1,\n2,\n3)"]],
              [:html, :attr, "attr-two", [:slim, :attrvalue, true, "call(1,\n2)"]]
            ],
            [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Content"]]]
          ],
          [:newline]
        ]
      end

      # To resolve the issues with the original parse tree, we capture each
      # line as its own expression, including leading whitespace, and group
      # them into a `:multi` expression.
      it do
        should parse_as [
          :multi,
          [
            :html, :tag, "tag",
            [
              :html, :attrs,
              [:html, :attr, "attr", [:escape, true, [:slim, :interpolate, "value"]]]
            ],
            [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Content"]]]
          ],
          [
            :html, :tag, "tag",
            [
              :html, :attrs,
              [
                :html, :attr, "attr",
                [:slim, :attrvalue, true, [:multi, [:code, "variable"]]]
              ]
            ],
            [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Content"]]]
          ],
          [
            :html, :tag, "tag",
            [
              :html, :attrs,
              [
                :html, :attr, "attr",
                [
                  :slim, :attrvalue, true,
                  [
                    :multi,
                    [:code, "call(1,"],
                    [:code, "2,"],
                    [:code, "3)"]
                  ]
                ]
              ]
            ],
            [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Content"]]]
          ],
          [
            :html, :tag, "tag",
            [
              :html, :attrs,
              [
                :html, :attr, "attr",
                [
                  :slim, :attrvalue, true,
                  [
                    :multi,
                    [:code, "call(1,"],
                    [:code, "     2,"],
                    [:code, "     3)"]
                  ]
                ]
              ]
            ],
            [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Content"]]]
          ],
          [
            :html, :tag, "tag",
            [
              :html, :attrs,
              [
                :html, :attr, "attr",
                [
                  :slim, :attrvalue, true,
                  [
                    :multi,
                    [:code, "call(1,"],
                    [:code, "     2,"],
                    [:code, "     3)"]
                  ]
                ]
              ],
              [
                :html, :attr, "attr-two",
                [
                  :slim, :attrvalue, true,
                  [
                    :multi,
                    [:code, "call(1,"],
                    [:code, "     2)"]
                  ]
                ]
              ]
            ],
            [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Content"]]]
          ]
        ]
      end
    end

    context "5) embedded code and big literals are captured differently" do
      let(:template) { <<~'SLIM' }
        ruby:
          klass = Class.new do
            def public
            end


            private

            def private
            end
          end

        doctype
        SLIM

      # While this parse tree *does* contain enough detail about line numbers
      # and spacing, the choice to lead each subsequent line with the previous
      # line's newline character makes calculating the correct column offsets
      # difficult, and the choice to use `:interpolate` expressions here is
      # needless extra work for our use case (Ruby should be treated literally,
      # everything else will be discarded).
      it do
        should officially_parse_as [
          :multi,
          [
            :slim, :embedded, "ruby",
            [
              :multi,
              [:newline],
              [:slim, :interpolate, "klass = Class.new do"],
              [:newline],
              [:slim, :interpolate, "\n  def public"],
              [:newline],
              [:slim, :interpolate, "\n  end"],
              [:newline],
              [:newline],
              [:slim, :interpolate, "\n\n"],
              [:newline],
              [:slim, :interpolate, "\n  private"],
              [:newline],
              [:slim, :interpolate, "\n"],
              [:newline],
              [:slim, :interpolate, "\n  def private"],
              [:newline],
              [:slim, :interpolate, "\n  end"],
              [:newline],
              [:slim, :interpolate, "\nend"],
              [:newline]
            ],
            [:html, :attrs]
          ],
          [:newline],
          [:html, :doctype, ""],
          [:newline]
        ]
      end

      # To resolve this, we capture each line as a `:static` expression, with
      # the content starting at the line and column we're tracking for
      # indentation.
      it do
        should parse_as [
          :multi,
          [
            :slim, :embedded, "ruby",
            [
              :multi,
              [:static, "klass = Class.new do"],
              [:static, "  def public"],
              [:static, "  end"],
              [:static, ""],
              [:static, ""],
              [:static, "  private"],
              [:static, ""],
              [:static, "  def private"],
              [:static, "  end"],
              [:static, "end"],
              [:static, ""]
            ],
            [:html, :attrs]
          ],
          [:html, :doctype, ""]
        ]
      end
    end
  end

  context "for line indicators" do
    context "like `/`" do
      context "code comments begin with `/` and produce no output" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          / Comment
          body
            / Another comment
              with

              multiple lines
            p Hello!
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:newline],
            [
              :html, :tag, "body",
              [:html, :attrs],
              [
                :multi,
                [:newline],
                [:newline],
                [:newline],
                [:newline],
                [:newline],
                [
                  :html, :tag, "p",
                  [:html, :attrs],
                  [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Hello!"]]]
                ],
                [:newline]
              ]
            ]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "body",
              [:html, :attrs],
              [
                :multi,
                [
                  :html, :tag, "p",
                  [:html, :attrs],
                  [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Hello!"]]]
                ]
              ]
            ]
          ]
        end
      end
    end

    context "like `/!`" do
      context "HTML comments begin with `/!`" do
        # Expected differences: #1, #5
        let(:template) { <<~'SLIM' }
          /! Comment
          body
            /! Another comment
              with multiple lines
            p Hello!
            /!
                First line determines indentation

                of the comment
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :comment,
              [:slim, :text, :verbatim, [:multi, [:slim, :interpolate, "Comment"]]]
            ],
            [:newline],
            [
              :html, :tag, "body",
              [:html, :attrs],
              [
                :multi,
                [:newline],
                [
                  :html, :comment,
                  [
                    :slim, :text, :verbatim,
                    [
                      :multi,
                      [:slim, :interpolate, "Another comment"],
                      [:newline],
                      [:slim, :interpolate, "\nwith multiple lines"]
                    ]
                  ]
                ],
                [:newline],
                [
                  :html, :tag, "p",
                  [:html, :attrs],
                  [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Hello!"]]]
                ],
                [:newline],
                [
                  :html, :comment,
                  [
                    :slim, :text, :verbatim,
                    [
                      :multi,
                      [:newline],
                      [:slim, :interpolate, "First line determines indentation"],
                      [:newline],
                      [:slim, :interpolate, "\n"],
                      [:newline],
                      [:slim, :interpolate, "\nof the comment"]
                    ]
                  ]
                ],
                [:newline]
              ]
            ]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :comment,
              [:slim, :text, :verbatim, [:multi, [:slim, :interpolate, "Comment"]]]
            ],
            [
              :html, :tag, "body",
              [:html, :attrs],
              [
                :multi,
                [
                  :html, :comment,
                  [
                    :slim, :text, :verbatim,
                    [
                      :multi,
                      [:slim, :interpolate, "Another comment"],
                      [:slim, :interpolate, "with multiple lines"]
                    ]
                  ]
                ],
                [
                  :html, :tag, "p",
                  [:html, :attrs],
                  [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Hello!"]]]
                ],
                [
                  :html, :comment,
                  [
                    :slim, :text, :verbatim,
                    [
                      :multi,
                      [:slim, :interpolate, "First line determines indentation"],
                      [:slim, :interpolate, ""],
                      [:slim, :interpolate, "of the comment"]
                    ]
                  ]
                ]
              ]
            ]
          ]
        end
      end
    end

    context "like `/[...]`" do
      context "conditional comments begin with `/[...]`" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          /[if IE]
              p Get a better browser.
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :condcomment, "if IE",
              [
                :multi,
                [:newline],
                [
                  :html, :tag, "p",
                  [:html, :attrs],
                  [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Get a better browser."]]]
                ],
                [:newline]
              ]
            ]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :condcomment, "if IE",
              [
                :multi,
                [
                  :html, :tag, "p",
                  [:html, :attrs],
                  [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Get a better browser."]]]
                ],
              ]
            ]
          ]
        end
      end
    end

    context "like `|`" do
      context "when text blocks starts with the `|` as line indicator" do
        # Expected diferences: #1
        let(:template) { <<~'SLIM' }
          | Text block
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :slim, :text, :verbatim,
              [:multi, [:slim, :interpolate, "Text block"]]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim, :text, :verbatim,
              [:multi, [:slim, :interpolate, "Text block"]]
            ]
          ]
        end
      end

      context "you can nest text blocks beneath tags" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          body
            | Text
        SLIM


        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "body",
              [:html, :attrs],
              [
                :multi,
                [:newline],
                [
                  :slim, :text, :verbatim,
                  [:multi, [:slim, :interpolate, "Text"]]
                ],
                [:newline]
              ]
            ]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "body",
              [:html, :attrs],
              [
                :multi,
                [
                  :slim, :text, :verbatim,
                  [:multi, [:slim, :interpolate, "Text"]]
                ]
              ]
            ]
          ]
        end
      end

      context "you can embed HTML code in the text which is not escaped" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          | <a href="http://slim-lang.com">slim-lang.com</a>
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :slim, :text, :verbatim,
              [:multi, [:slim, :interpolate, '<a href="http://slim-lang.com">slim-lang.com</a>']]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim, :text, :verbatim,
              [:multi, [:slim, :interpolate, '<a href="http://slim-lang.com">slim-lang.com</a>']]
            ]
          ]
        end
      end

      context "multiple lines can be indented beneath the first text line" do
        # Expected differences: #1, #5
        let(:template) { <<~'SLIM' }
          |  Text
              block

              with

              multiple
            lines
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :slim,
              :text,
              :verbatim,
              [
                :multi,
                [:slim, :interpolate, " Text"],
                [:newline],
                [:slim, :interpolate, "\n  block"],
                [:newline],
                [:slim, :interpolate, "\n"],
                [:newline],
                [:slim, :interpolate, "\n  with"],
                [:newline],
                [:slim, :interpolate, "\n"],
                [:newline],
                [:slim, :interpolate, "\n  multiple"],
                [:newline],
                [:slim, :interpolate, "\nlines"]
              ]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim,
              :text,
              :verbatim,
              [
                :multi,
                [:slim, :interpolate, " Text"],
                [:slim, :interpolate, "  block"],
                [:slim, :interpolate, ""],
                [:slim, :interpolate, "  with"],
                [:slim, :interpolate, ""],
                [:slim, :interpolate, "  multiple"],
                [:slim, :interpolate, "lines"]
              ]
            ]
          ]
        end
      end

      context "the first line of a text block determines the indentation" do
        # Expected differences: #1, #5
        let(:template) { <<~'SLIM' }
          |

            Text
              block

              with

              multiple
            lines
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :slim,
              :text,
              :verbatim,
              [
                :multi,
                [:newline],
                [:newline],
                [:slim, :interpolate, "Text"],
                [:newline],
                [:slim, :interpolate, "\n  block"],
                [:newline],
                [:slim, :interpolate, "\n"],
                [:newline],
                [:slim, :interpolate, "\n  with"],
                [:newline],
                [:slim, :interpolate, "\n"],
                [:newline],
                [:slim, :interpolate, "\n  multiple"],
                [:newline],
                [:slim, :interpolate, "\nlines"]
              ]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim,
              :text,
              :verbatim,
              [
                :multi,
                [:slim, :interpolate, ""],
                [:slim, :interpolate, "Text"],
                [:slim, :interpolate, "  block"],
                [:slim, :interpolate, ""],
                [:slim, :interpolate, "  with"],
                [:slim, :interpolate, ""],
                [:slim, :interpolate, "  multiple"],
                [:slim, :interpolate, "lines"]
              ]
            ],
          ]
        end
      end
    end

    context "like `'`" do
      context "text blocks with trailing white space starts with the `'` as line indicator" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          ' Text block
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:slim, :text, :verbatim, [:multi, [:slim, :interpolate, "Text block"]]],
            [:static, " "],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [:slim, :text, :verbatim, [:multi, [:slim, :interpolate, "Text block"]]],
            [:static, " "],
          ]
        end
      end

      context "this is especially useful if you use tags behind a text block" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          ' Link to
          a href="http://slim-lang.com" slim-lang.com
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:slim, :text, :verbatim, [:multi, [:slim, :interpolate, "Link to"]]],
            [:static, " "],
            [:newline],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "http://slim-lang.com"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "slim-lang.com"]]]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [:slim, :text, :verbatim, [:multi, [:slim, :interpolate, "Link to"]]],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "http://slim-lang.com"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "slim-lang.com"]]]
            ]
          ]
        end
      end

      context "multiple lines can be indented beneath the first text line" do
        # Expected differences: #1, #5
        let(:template) { <<~'SLIM' }
          '  Text
              block

              with

              multiple
            lines
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :slim,
              :text,
              :verbatim,
              [
                :multi,
                [:slim, :interpolate, " Text"],
                [:newline],
                [:slim, :interpolate, "\n  block"],
                [:newline],
                [:slim, :interpolate, "\n"],
                [:newline],
                [:slim, :interpolate, "\n  with"],
                [:newline],
                [:slim, :interpolate, "\n"],
                [:newline],
                [:slim, :interpolate, "\n  multiple"],
                [:newline],
                [:slim, :interpolate, "\nlines"]
              ]
            ],
            [:static, " "],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim,
              :text,
              :verbatim,
              [
                :multi,
                [:slim, :interpolate, " Text"],
                [:slim, :interpolate, "  block"],
                [:slim, :interpolate, ""],
                [:slim, :interpolate, "  with"],
                [:slim, :interpolate, ""],
                [:slim, :interpolate, "  multiple"],
                [:slim, :interpolate, "lines"]
              ]
            ],
            [:static, " "]
          ]
        end
      end

      context "the first line of a text block determines the indentation" do
        # Expected differences: #1, #5
        let(:template) { <<~'SLIM' }
          '

            Text
              block

              with

              multiple
            lines
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :slim,
              :text,
              :verbatim,
              [
                :multi,
                [:newline],
                [:newline],
                [:slim, :interpolate, "Text"],
                [:newline],
                [:slim, :interpolate, "\n  block"],
                [:newline],
                [:slim, :interpolate, "\n"],
                [:newline],
                [:slim, :interpolate, "\n  with"],
                [:newline],
                [:slim, :interpolate, "\n"],
                [:newline],
                [:slim, :interpolate, "\n  multiple"],
                [:newline],
                [:slim, :interpolate, "\nlines"]
              ]
            ],
            [:static, " "],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim,
              :text,
              :verbatim,
              [
                :multi,
                [:slim, :interpolate, ""],
                [:slim, :interpolate, "Text"],
                [:slim, :interpolate, "  block"],
                [:slim, :interpolate, ""],
                [:slim, :interpolate, "  with"],
                [:slim, :interpolate, ""],
                [:slim, :interpolate, "  multiple"],
                [:slim, :interpolate, "lines"]
              ]
            ],
            [:static, " "]
          ]
        end
      end
    end

    context "like `-`" do
      context "the dash `-` denotes arbitrary control code" do
        # Expected differences: #1, #2, #3
        let(:template) { <<~'SLIM' }
          - greeting = 'Hello, World!'
          - if false
            | Not true
          - else
            = greeting
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:slim, :control, "greeting = 'Hello, World!'", [:multi, [:newline]]],
            [
              :slim, :control, "if false",
              [
                :multi,
                [:newline],
                [:slim, :text, :verbatim, [:multi, [:slim, :interpolate, "Not true"]]],
                [:newline]
              ]
            ],
            [
              :slim, :control, "else",
              [
                :multi,
                [:newline],
                [
                  :slim, :output, true, "greeting",
                  [:multi, [:newline]]
                ]
              ]
            ]
          ]
        end

        it do
          should parse_as [
            :multi,
            [:slim, :control, [:multi, [:code, "greeting = 'Hello, World!'"]], [:multi]],
            [
              :slim, :control, [:multi, [:code, "if false"]],
              [
                :multi,
                [:slim, :text, :verbatim, [:multi, [:slim, :interpolate, "Not true"]]]
              ]
            ],
            [
              :slim, :control, [:multi, [:code, "else"]],
              [
                :multi,
                [
                  :slim, :output, true, [:multi, [:code, "greeting"]],
                  [:multi]
                ]
              ]
            ]
          ]
        end
      end

      context "complex code can be broken with backslash `\\`" do
        # Expected differences: #1, #2, #3
        let(:template) { <<~'SLIM' }
          - greeting = 'Hello, '+\
              \
              'World!'
          - if false
            | Not true
          - else
            = greeting
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:slim, :control, "greeting = 'Hello, '+\\\n\\\n'World!'", [:multi, [:newline]]],
            [
              :slim, :control, "if false",
              [
                :multi,
                [:newline],
                [:slim, :text, :verbatim, [:multi, [:slim, :interpolate, "Not true"]]],
                [:newline]
              ]
            ],
            [
              :slim, :control, "else",
              [
                :multi,
                [:newline],
                [
                  :slim, :output, true, "greeting",
                  [:multi, [:newline]]
                ]
              ]
            ]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim, :control,
              [
                :multi,
                [:code, "greeting = 'Hello, '+\\"],
                [:code, "  \\"],
                [:code, "  'World!'"]
              ],
              [:multi]
            ],
            [
              :slim, :control, [:multi, [:code, "if false"]],
              [
                :multi,
                [:slim, :text, :verbatim, [:multi, [:slim, :interpolate, "Not true"]]]
              ]
            ],
            [
              :slim, :control, [:multi, [:code, "else"]],
              [
                :multi,
                [
                  :slim, :output, true, [:multi, [:code, "greeting"]],
                  [:multi]
                ]
              ]
            ]
          ]
        end
      end

      context "you can also write loops like this" do
        # Expected differences: #1, #2, #3
        let(:template) { <<~'SLIM' }
          - items = [{name: 'table', price: 10}, {name: 'chair', price: 5}]
          table#items
            - for item in items do
              tr
                td.name = item[:name]
                td.price = item[:price]
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :slim, :control,
              "items = [{name: 'table', price: 10}, {name: 'chair', price: 5}]",
              [:multi, [:newline]]
            ],
            [
              :html, :tag, "table",
              [:html, :attrs, [:html, :attr, "id", [:static, "items"]]],
              [:multi,
                [:newline],
                [
                  :slim, :control, "for item in items do",
                  [
                    :multi,
                    [:newline],
                    [
                      :html, :tag, "tr",
                      [:html, :attrs],
                      [
                        :multi,
                        [:newline],
                        [
                          :html, :tag, "td",
                          [:html, :attrs, [:html, :attr, "class", [:static, "name"]]],
                          [:slim, :output, true, "item[:name]", [:multi, [:newline]]]
                        ],
                        [
                          :html, :tag, "td",
                          [:html, :attrs, [:html, :attr, "class", [:static, "price"]]],
                          [:slim, :output, true, "item[:price]", [:multi, [:newline]]]
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim, :control,
              [:multi, [:code, "items = [{name: 'table', price: 10}, {name: 'chair', price: 5}]"]],
              [:multi]
            ],
            [
              :html, :tag, "table",
              [:html, :attrs, [:html, :attr, "id", [:static, "items"]]],
              [:multi,
                [
                  :slim, :control, [:multi, [:code, "for item in items do"]],
                  [
                    :multi,
                    [
                      :html, :tag, "tr",
                      [:html, :attrs],
                      [
                        :multi,
                        [
                          :html, :tag, "td",
                          [:html, :attrs, [:html, :attr, "class", [:static, "name"]]],
                          [:slim, :output, true, [:multi, [:code, "item[:name]"]], [:multi]]
                        ],
                        [
                          :html, :tag, "td",
                          [:html, :attrs, [:html, :attr, "class", [:static, "price"]]],
                          [:slim, :output, true, [:multi, [:code, "item[:price]"]], [:multi]]
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]
        end
      end

      context "the `do` keyword can be omitted" do
        # Expected differences: #1, #2, #3
        let(:template) { <<~'SLIM' }
          - items = [{name: 'table', price: 10}, {name: 'chair', price: 5}]
          table#items
            - for item in items
              tr
                td.name = item[:name]
                td.price = item[:price]
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :slim, :control,
              "items = [{name: 'table', price: 10}, {name: 'chair', price: 5}]",
              [:multi, [:newline]]
            ],
            [
              :html, :tag, "table",
              [:html, :attrs, [:html, :attr, "id", [:static, "items"]]],
              [:multi,
                [:newline],
                [
                  :slim, :control, "for item in items",
                  [
                    :multi,
                    [:newline],
                    [
                      :html, :tag, "tr",
                      [:html, :attrs],
                      [
                        :multi,
                        [:newline],
                        [
                          :html, :tag, "td",
                          [:html, :attrs, [:html, :attr, "class", [:static, "name"]]],
                          [:slim, :output, true, "item[:name]", [:multi, [:newline]]]
                        ],
                        [
                          :html, :tag, "td",
                          [:html, :attrs, [:html, :attr, "class", [:static, "price"]]],
                          [:slim, :output, true, "item[:price]", [:multi, [:newline]]]
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim, :control,
              [:multi, [:code, "items = [{name: 'table', price: 10}, {name: 'chair', price: 5}]"]],
              [:multi]
            ],
            [
              :html, :tag, "table",
              [:html, :attrs, [:html, :attr, "id", [:static, "items"]]],
              [:multi,
                [
                  :slim, :control, [:multi, [:code, "for item in items"]],
                  [
                    :multi,
                    [
                      :html, :tag, "tr",
                      [:html, :attrs],
                      [
                        :multi,
                        [
                          :html, :tag, "td",
                          [:html, :attrs, [:html, :attr, "class", [:static, "name"]]],
                          [:slim, :output, true, [:multi, [:code, "item[:name]"]], [:multi]]
                        ],
                        [
                          :html, :tag, "td",
                          [:html, :attrs, [:html, :attr, "class", [:static, "price"]]],
                          [:slim, :output, true, [:multi, [:code, "item[:price]"]], [:multi]]
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]
        end
      end
    end

    context "like `=`" do
      context "the equal sign `=` produces dynamic output" do
        # Expected differences: #1, #3
        let(:template) { <<~'SLIM' }
          = 7*7
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:slim, :output, true, "7*7", [:multi, [:newline]]]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim, :output, true,
              [:multi, [:code, "7*7"]],
              [:multi]
            ]
          ]
        end
      end

      context "dynamic output is escaped by default" do
        # Expected differences: #1, #3
        let(:template) { <<~'SLIM' }
          = '<script>evil();</script>'
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:slim, :output, true, "'<script>evil();</script>'", [:multi, [:newline]]]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim, :output, true,
              [:multi, [:code, "'<script>evil();</script>'"]],
              [:multi]
            ]
          ]
        end
      end

      context "long code lines can be broken with `\\`" do
        # Expected differences: #1, #3
        let(:template) { <<~'SLIM' }
          = (0..10).map do |i|\
              2**i \
            end.join(', ')
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:slim, :output, true, "(0..10).map do |i|\\\n2**i \\\nend.join(', ')", [:multi, [:newline]]]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim, :output, true,
              [
                :multi,
                [:code, "(0..10).map do |i|\\"],
                [:code, "  2**i \\"],
                [:code, "end.join(', ')"]
              ],
              [:multi]
            ]
          ]
        end
      end

      context "you don't need the explicit `\\` if the line ends with a comma `,`" do
        # Expected differences: #1, #3
        let(:template) { <<~'SLIM' }
          = call('arg1',
                 'arg2',
                 'arg3')
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:slim, :output, true, "call('arg1',\n'arg2',\n'arg3')", [:multi, [:newline]]]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim, :output, true,
              [
                :multi,
                [:code, "call('arg1',"],
                [:code, "     'arg2',"],
                [:code, "     'arg3')"]
              ],
              [:multi]
            ]
          ]
        end
      end

      context "the equal sign with modifier `=>` produces dynamic output with a trailing white space" do
        # Expected differences: #1, #3
        let(:template) { <<~'SLIM' }
          => 7*7
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:slim, :output, true, "7*7", [:multi, [:newline]]],
            [:static, " "]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim, :output, true,
              [:multi, [:code, "7*7"]],
              [:multi]
            ],
            [:static, " "]
          ]
        end
      end

      context "the equal sign with modifier `=<` produces dynamic output with a leading white space" do
        # Expected differences: #1, #3
        let(:template) { <<~'SLIM' }
          =< 7*7
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:static, " "],
            [:slim, :output, true, "7*7", [:multi, [:newline]]],
          ]
        end

        it do
          should parse_as [
            :multi,
            [:static, " "],
            [
              :slim, :output, true,
              [:multi, [:code, "7*7"]],
              [:multi]
            ]
          ]
        end
      end

      context "the equal sign with modifiers `=<>` produces dynamic output with a leading and trailing white space" do
        # Expected differences: #1, #3
        let(:template) { <<~'SLIM' }
          =<> 7*7
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:static, " "],
            [:slim, :output, true, "7*7", [:multi, [:newline]]],
            [:static, " "]
          ]
        end

        it do
          should parse_as [
            :multi,
            [:static, " "],
            [
              :slim, :output, true,
              [:multi, [:code, "7*7"]],
              [:multi]
            ],
            [:static, " "]
          ]
        end
      end
    end

    context "like `==`" do
      context "double equal sign `==` produces dynamic output without HTML escaping" do
        # Expected differences: #1, #3
        let(:template) { <<~'SLIM' }
          == '<script>evil();</script>'
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:slim, :output, false, "'<script>evil();</script>'", [:multi, [:newline]]]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim, :output, false,
              [:multi, [:code, "'<script>evil();</script>'"]],
              [:multi]
            ]
          ]
        end
      end

      context "the equal sign with modifier `=>` produces dynamic output with a trailing white space" do
        # Expected differences: #1, #3
        let(:template) { <<~'SLIM' }
          ==> 7*7
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:slim, :output, false, "7*7", [:multi, [:newline]]],
            [:static, " "]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :slim, :output, false,
              [:multi, [:code, "7*7"]],
              [:multi]
            ],
            [:static, " "]
          ]
        end
      end

      context "the equal sign with modifier `=<` produces dynamic output with a leading white space" do
        # Expected differences: #1, #3
        let(:template) { <<~'SLIM' }
          ==< 7*7
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:static, " "],
            [:slim, :output, false, "7*7", [:multi, [:newline]]]
          ]
        end

        it do
          should parse_as [
            :multi,
            [:static, " "],
            [
              :slim, :output, false,
              [:multi, [:code, "7*7"]],
              [:multi]
            ]
          ]
        end
      end

      context "the equal sign with modifiers `=<>` produces dynamic output with a leading and trailing white space" do
        # Expected differences: #1, #3
        let(:template) { <<~'SLIM' }
          ==<> 7*7
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:static, " "],
            [:slim, :output, false, "7*7", [:multi, [:newline]]],
            [:static, " "]
          ]
        end

        it do
          should parse_as [
            :multi,
            [:static, " "],
            [
              :slim, :output, false,
              [:multi, [:code, "7*7"]],
              [:multi]
            ],
            [:static, " "]
          ]
        end
      end
    end

    context "like `<`" do
      context "HTML can be written directly" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          <a href="http://slim-lang.com">slim-lang.com</a>
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :multi,
              [:slim, :interpolate, '<a href="http://slim-lang.com">slim-lang.com</a>'],
              [:multi, [:newline]]
            ]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :multi,
              [:slim, :interpolate, '<a href="http://slim-lang.com">slim-lang.com</a>'],
              [:multi]
            ]
          ]
        end
      end

      context "HTML tags allow nested blocks inside" do
        # Expected differences: #1, #2, #3
        let(:template) { <<~'SLIM' }
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

        it do
          should officially_parse_as [
            :multi,
            [:multi,
              [:slim, :interpolate, "<html>"],
              [
                :multi,
                [:newline],
                [
                  :multi,
                  [:slim, :interpolate, "<head>"],
                  [
                    :multi,
                    [:newline],
                    [
                      :html, :tag, "title",
                      [:html, :attrs],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Example"]]]
                    ],
                    [:newline]
                  ]
                ],
                [:multi, [:slim, :interpolate, "</head>"], [:multi, [:newline]]],
                [
                  :html, :tag, "body",
                  [:html, :attrs],
                  [
                    :multi,
                    [:newline],
                    [
                      :slim, :control, "if true",
                      [
                        :multi,
                        [:newline],
                        [:slim, :text, :verbatim, [:multi, [:slim, :interpolate, "yes"]]],
                        [:newline]
                      ]
                    ],
                    [
                      :slim, :control, "else",
                      [
                        :multi,
                        [:newline],
                        [:slim, :text, :verbatim, [:multi, [:slim, :interpolate, "no"]]],
                        [:newline]
                      ]
                    ]
                  ]
                ]
              ]
            ],
            [:multi, [:slim, :interpolate, "</html>"], [:multi, [:newline]]],
          ]
        end

        it do
          should parse_as [
            :multi,
            [:multi,
              [:slim, :interpolate, "<html>"],
              [
                :multi,
                [
                  :multi,
                  [:slim, :interpolate, "<head>"],
                  [
                    :multi,
                    [
                      :html, :tag, "title",
                      [:html, :attrs],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Example"]]]
                    ]
                  ]
                ],
                [:multi, [:slim, :interpolate, "</head>"], [:multi]],
                [
                  :html, :tag, "body",
                  [:html, :attrs],
                  [
                    :multi,
                    [
                      :slim, :control,
                      [:multi, [:code, "if true"]],
                      [
                        :multi,
                        [:slim, :text, :verbatim, [:multi, [:slim, :interpolate, "yes"]]]
                      ]
                    ],
                    [
                      :slim, :control,
                      [:multi, [:code, "else"]],
                      [
                        :multi,
                        [:slim, :text, :verbatim, [:multi, [:slim, :interpolate, "no"]]]
                      ]
                    ]
                  ]
                ]
              ]
            ],
            [:multi, [:slim, :interpolate, "</html>"], [:multi]],
          ]
        end
      end
    end
  end

  context "for HTML tags" do
    context "like doctype tags" do
      context "you can output the XML version using the doctype tag" do
        # Expeced differences: #1
        let(:template) { <<~'SLIM' }
          doctype xml
          doctype xml ISO-8859-1
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:html, :doctype, "xml"],
            [:newline],
            [:html, :doctype, "xml ISO-8859-1"],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [:html, :doctype, "xml"],
            [:html, :doctype, "xml ISO-8859-1"]
          ]
        end
      end

      context "in XHTML mode the following doctypes are supported" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          doctype html
          doctype 5
          doctype 1.1
          doctype strict
          doctype frameset
          doctype mobile
          doctype basic
          doctype transitional
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:html, :doctype, "html"],
            [:newline],
            [:html, :doctype, "5"],
            [:newline],
            [:html, :doctype, "1.1"],
            [:newline],
            [:html, :doctype, "strict"],
            [:newline],
            [:html, :doctype, "frameset"],
            [:newline],
            [:html, :doctype, "mobile"],
            [:newline],
            [:html, :doctype, "basic"],
            [:newline],
            [:html, :doctype, "transitional"],
            [:newline],
          ]
        end

        it do
          should parse_as [
            :multi,
            [:html, :doctype, "html"],
            [:html, :doctype, "5"],
            [:html, :doctype, "1.1"],
            [:html, :doctype, "strict"],
            [:html, :doctype, "frameset"],
            [:html, :doctype, "mobile"],
            [:html, :doctype, "basic"],
            [:html, :doctype, "transitional"],
          ]
        end
      end
    end

    context "like closed tags" do
      context "you can close tags explicitly by appending a trailing `/`" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          div id="not-closed"
          .closed/
          #closed/
          div id="closed"/
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "div",
              [
                :html, :attrs,
                [:html, :attr, "id", [:escape, true, [:slim, :interpolate, "not-closed"]]]
              ],
              [:multi, [:newline]]
            ],
            [
              :html, :tag, ".",
              [
                :html, :attrs,
                [:html, :attr, "class", [:static, "closed"]]
              ]
            ],
            [:newline],
            [
              :html, :tag, "#",
              [
                :html, :attrs,
                [:html, :attr, "id", [:static, "closed"]]
              ]
            ],
            [:newline],
            [
              :html, :tag, "div",
              [
                :html, :attrs,
                [:html, :attr, "id", [:escape, true, [:slim, :interpolate, "closed"]]]
              ]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "div",
              [
                :html, :attrs,
                [:html, :attr, "id", [:escape, true, [:slim, :interpolate, "not-closed"]]]
              ],
              [:multi]
            ],
            [
              :html, :tag, ".",
              [
                :html, :attrs,
                [:html, :attr, "class", [:static, "closed"]]
              ]
            ],
            [
              :html, :tag, "#",
              [
                :html, :attrs,
                [:html, :attr, "id", [:static, "closed"]]
              ]
            ],
            [
              :html, :tag, "div",
              [
                :html, :attrs,
                [:html, :attr, "id", [:escape, true, [:slim, :interpolate, "closed"]]]
              ]
            ]
          ]
        end
      end

      context "standard html tags (img, br, ...) are closed automatically" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          img src="image.png"
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "img",
              [
                :html, :attrs,
                [:html, :attr, "src", [:escape, true, [:slim, :interpolate, "image.png"]]]
              ],
              [:multi, [:newline]]
            ],
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "img",
              [
                :html, :attrs,
                [:html, :attr, "src", [:escape, true, [:slim, :interpolate, "image.png"]]]
              ],
              [:multi]
            ],
          ]
        end
      end
    end

    context "like trailing and leading whitespace" do
      context "you can force a trailing whitespace behind a tag by adding `>`" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          a#closed> class="test" /
          a#closed> class="test"/
          a> href='url1' Link1
          a< href='url1' Link1
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "id", [:static, "closed"]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "test"]]]
              ]
            ],
            [:static, " "],
            [:newline],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "id", [:static, "closed"]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "test"]]]
              ]
            ],
            [:static, " "],
            [:newline],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "url1"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link1"]]]
            ],
            [:static, " "],
            [:newline],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "url1"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link1"]]]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "id", [:static, "closed"]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "test"]]]
              ]
            ],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "id", [:static, "closed"]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "test"]]]
              ]
            ],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "url1"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link1"]]]
            ],
            [:static, " "],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "url1"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link1"]]]
            ]
          ]
        end
      end

      context "only one trailing whitespace is added if you combine `>` and `=>`" do
        # Expected differences: #1, #3
        let(:template) { <<~'SLIM' }
          a> => 'Text1'
          a => 'Text2'
          a> = 'Text3'
          a>= 'Text4'
          a=> 'Text5'
          a<= 'Text6'
          a=< 'Text7'
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "a",
              [:html, :attrs],
              [:slim, :output, true, "'Text1'", [:multi, [:newline]]]
            ],
            [:static, " "],
            [
              :html, :tag, "a",
              [:html, :attrs],
              [:slim, :output, true, "'Text2'", [:multi, [:newline]]]
            ],
            [:static, " "],
            [
              :html, :tag, "a",
              [:html, :attrs],
              [:slim, :output, true, "'Text3'", [:multi, [:newline]]]
            ],
            [:static, " "],
            [
              :html, :tag, "a",
              [:html, :attrs],
              [:slim, :output, true, "'Text4'", [:multi, [:newline]]]
            ],
            [:static, " "],
            [
              :html, :tag, "a",
              [:html, :attrs],
              [:slim, :output, true, "'Text5'", [:multi, [:newline]]]
            ],
            [:static, " "],
            [:static, " "],
            [
              :html, :tag, "a",
              [:html, :attrs],
              [:slim, :output, true, "'Text6'", [:multi, [:newline]]]
            ],
            [:static, " "],
            [
              :html, :tag, "a",
              [:html, :attrs],
              [:slim, :output, true, "'Text7'", [:multi, [:newline]]]
            ]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "a",
              [:html, :attrs],
              [
                :slim, :output, true, [:multi, [:code, "'Text1'"]],
                [:multi]
              ]
            ],
            [:static, " "],
            [
              :html, :tag, "a",
              [:html, :attrs],
              [
                :slim, :output, true, [:multi, [:code, "'Text2'"]],
                [:multi]
              ]
            ],
            [:static, " "],
            [
              :html, :tag, "a",
              [:html, :attrs],
              [
                :slim, :output, true, [:multi, [:code, "'Text3'"]],
                [:multi]
              ]
            ],
            [:static, " "],
            [
              :html, :tag, "a",
              [:html, :attrs],
              [
                :slim, :output, true, [:multi, [:code, "'Text4'"]],
                [:multi]
              ]
            ],
            [:static, " "],
            [
              :html, :tag, "a",
              [:html, :attrs],
              [
                :slim, :output, true, [:multi, [:code, "'Text5'"]],
                [:multi]
              ]
            ],
            [:static, " "],
            [:static, " "],
            [
              :html, :tag, "a",
              [:html, :attrs],
              [
                :slim, :output, true, [:multi, [:code, "'Text6'"]],
                [:multi]
              ]
            ],
            [:static, " "],
            [
              :html, :tag, "a",
              [:html, :attrs],
              [
                :slim, :output, true, [:multi, [:code, "'Text7'"]],
                [:multi]
              ]
            ]
          ]
        end
      end

      context "you can force a leading whitespace before a tag by adding `<`" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          a#closed< class="test" /
          a#closed< class="test"/
          a< href='url1' Link1
          a< href='url2' Link2
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "id", [:static, "closed"]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "test"]]]
              ]
            ],
            [:newline],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "id", [:static, "closed"]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "test"]]]
              ]
            ],
            [:newline],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "url1"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link1"]]]
            ],
            [:newline],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "url2"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link2"]]]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "id", [:static, "closed"]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "test"]]]
              ]
            ],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "id", [:static, "closed"]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "test"]]]
              ]
            ],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "url1"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link1"]]]
            ],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "url2"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link2"]]]
            ]
          ]
        end
      end

      context "you can also combine `<` and `>`" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          a#closed<> class="test" /
          a#closed>< class="test"/
          a<> href='url1' Link1
          a<> href='url2' Link2
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "id", [:static, "closed"]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "test"]]]
              ]
            ],
            [:static, " "],
            [:newline],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "id", [:static, "closed"]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "test"]]]
              ]
            ],
            [:static, " "],
            [:newline],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "url1"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link1"]]]
            ],
            [:static, " "],
            [:newline],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "url2"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link2"]]]
            ],
            [:static, " "],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "id", [:static, "closed"]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "test"]]]
              ]
            ],
            [:static, " "],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "id", [:static, "closed"]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "test"]]]
              ]
            ],
            [:static, " "],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "url1"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link1"]]]
            ],
            [:static, " "],
            [:static, " "],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "url2"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link2"]]]
            ],
            [:static, " "]
          ]
        end
      end
    end

    context "like inline tags" do
      context "you may want to be a little more compact and inline the tags" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          ul
            li.first: a href="/first" First
            li: a href="/second" Second
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "ul",
              [:html, :attrs],
              [
                :multi,
                [:newline],
                [
                  :html, :tag, "li",
                  [
                    :html, :attrs,
                    [:html, :attr, "class", [:static, "first"]]
                  ],
                  [
                    :multi,
                    [
                      :html, :tag, "a",
                      [
                        :html, :attrs,
                        [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "/first"]]]
                      ],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "First"]]]
                    ]
                  ]
                ],
                [:newline],
                [
                  :html, :tag, "li",
                  [:html, :attrs],
                  [
                    :multi,
                    [
                      :html, :tag, "a",
                      [
                        :html, :attrs,
                        [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "/second"]]]
                      ],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Second"]]]
                    ]
                  ]
                ],
                [:newline]
              ]
            ]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "ul",
              [:html, :attrs],
              [
                :multi,
                [
                  :html, :tag, "li",
                  [
                    :html, :attrs,
                    [:html, :attr, "class", [:static, "first"]]
                  ],
                  [
                    :multi,
                    [
                      :html, :tag, "a",
                      [
                        :html, :attrs,
                        [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "/first"]]]
                      ],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "First"]]]
                    ]
                  ]
                ],
                [
                  :html, :tag, "li",
                  [:html, :attrs],
                  [
                    :multi,
                    [
                      :html, :tag, "a",
                      [
                        :html, :attrs,
                        [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "/second"]]]
                      ],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Second"]]]
                    ]
                  ]
                ]
              ]
            ]
          ]
        end
      end

      context "you can wrap the attributes for readability" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
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

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "ul",
              [:html, :attrs],
              [
                :multi,
                [:newline],
                [
                  :html, :tag, "li",
                  [
                    :html, :attrs,
                    [:html, :attr, "class", [:static, "first"]]
                  ],
                  [
                    :multi,
                    [
                      :html, :tag, "a",
                      [
                        :html, :attrs,
                        [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "/first"]]]
                      ],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "First"]]]
                    ]
                  ]
                ],
                [:newline],
                [
                  :html, :tag, "li",
                  [:html, :attrs],
                  [
                    :multi,
                    [
                      :html, :tag, "a",
                      [
                        :html, :attrs,
                        [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "/second"]]]
                      ],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Second"]]]
                    ]
                  ]
                ],
                [:newline],
                [
                  :html, :tag, "li",
                  [:html, :attrs],
                  [
                    :multi,
                    [:newline],
                    [
                      :html, :tag, "a",
                      [
                        :html, :attrs,
                        [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "http://slim-lang.com"]]],
                        [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "important"]]]
                      ],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link"]]]
                    ],
                    [:newline]
                  ]
                ],
                [
                  :html, :tag, "li",
                  [:html, :attrs],
                  [
                    :multi,
                    [:newline],
                    [
                      :html, :tag, "a",
                      [
                        :html, :attrs,
                        [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "http://slim-lang.com"]]],
                        [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "important"]]]
                      ],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link"]]]
                    ],
                    [:newline]
                  ]
                ],
                [
                  :html, :tag, "li",
                  [:html, :attrs],
                  [
                    :multi,
                    [:newline],
                    [
                      :html, :tag, "a",
                      [
                        :html, :attrs,
                        [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "http://slim-lang.com"]]],
                        [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "important"]]]
                      ],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link"]]]
                    ],
                    [:newline]
                  ]
                ]
              ]
            ]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "ul",
              [:html, :attrs],
              [
                :multi,
                [
                  :html, :tag, "li",
                  [
                    :html, :attrs,
                    [:html, :attr, "class", [:static, "first"]]
                  ],
                  [
                    :multi,
                    [
                      :html, :tag, "a",
                      [
                        :html, :attrs,
                        [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "/first"]]]
                      ],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "First"]]]
                    ]
                  ]
                ],
                [
                  :html, :tag, "li",
                  [:html, :attrs],
                  [
                    :multi,
                    [
                      :html, :tag, "a",
                      [
                        :html, :attrs,
                        [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "/second"]]]
                      ],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Second"]]]
                    ]
                  ]
                ],
                [
                  :html, :tag, "li",
                  [:html, :attrs],
                  [
                    :multi,
                    [
                      :html, :tag, "a",
                      [
                        :html, :attrs,
                        [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "http://slim-lang.com"]]],
                        [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "important"]]]
                      ],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link"]]]
                    ]
                  ]
                ],
                [
                  :html, :tag, "li",
                  [:html, :attrs],
                  [
                    :multi,
                    [
                      :html, :tag, "a",
                      [
                        :html, :attrs,
                        [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "http://slim-lang.com"]]],
                        [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "important"]]]
                      ],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link"]]]
                    ]
                  ]
                ],
                [
                  :html, :tag, "li",
                  [:html, :attrs],
                  [
                    :multi,
                    [
                      :html, :tag, "a",
                      [
                        :html, :attrs,
                        [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "http://slim-lang.com"]]],
                        [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "important"]]]
                      ],
                      [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link"]]]
                    ]
                  ]
                ]
              ]
            ]
          ]
        end
      end

      context "wrapped attributes can span lines" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          a(href="http://slim-lang.com"

              class="important") Link

          dl(
            itemprop='address'
            itemscope
            itemtype='http://schema.org/PostalAddress'
          )
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:newline],
            [:newline],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "http://slim-lang.com"]]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "important"]]]
              ],
              [
                :slim, :text, :inline,
                [:multi, [:slim, :interpolate, "Link"], [:newline]]]
            ],
            [:newline],
            [:newline],
            [:newline],
            [:newline],
            [:newline],
            [
              :html, :tag, "dl",
              [
                :html, :attrs,
                [:html, :attr, "itemprop", [:escape, true, [:slim, :interpolate, "address"]]],
                [:html, :attr, "itemscope", [:multi]],
                [:html, :attr, "itemtype", [:escape, true, [:slim, :interpolate, "http://schema.org/PostalAddress"]]]
              ],
              [:multi, [:newline]]
            ],
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "http://slim-lang.com"]]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "important"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link"], [:slim, :interpolate, ""]]]
            ],
            [
              :html, :tag, "dl",
              [
                :html, :attrs,
                [:html, :attr, "itemprop", [:escape, true, [:slim, :interpolate, "address"]]],
                [:html, :attr, "itemscope", [:multi]],
                [:html, :attr, "itemtype", [:escape, true, [:slim, :interpolate, "http://schema.org/PostalAddress"]]]
              ],
              [:multi]
            ]
          ]
        end
      end

      context "attribute wrappers and assignment may use spaces around them" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          h1 id = "logo" Logo
          h2 [ id = "tagline" ] Tagline
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "h1",
              [
                :html, :attrs,
                [:html, :attr, "id", [:escape, true, [:slim, :interpolate, "logo"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Logo"]]]
            ],
            [:newline],
            [
              :html, :tag, "h2",
              [
                :html, :attrs,
                [:html, :attr, "id", [:escape, true, [:slim, :interpolate, "tagline"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Tagline"]]]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "h1",
              [
                :html, :attrs,
                [:html, :attr, "id", [:escape, true, [:slim, :interpolate, "logo"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Logo"]]]
            ],
            [
              :html, :tag, "h2",
              [
                :html, :attrs,
                [:html, :attr, "id", [:escape, true, [:slim, :interpolate, "tagline"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Tagline"]]]
            ],
          ]
        end
      end

      context "you can use single or double quotes for simple text attributes" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          a href="http://slim-lang.com" title='Slim Homepage' Goto the Slim homepage
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "http://slim-lang.com"]]],
                [:html, :attr, "title", [:escape, true, [:slim, :interpolate, "Slim Homepage"]]]
              ],
              [
                :slim, :text, :inline,
                [
                  :multi,
                  [:slim, :interpolate, "Goto the Slim homepage"]
                ]
              ]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "http://slim-lang.com"]]],
                [:html, :attr, "title", [:escape, true, [:slim, :interpolate, "Slim Homepage"]]]
              ],
              [
                :slim, :text, :inline,
                [
                  :multi,
                  [:slim, :interpolate, "Goto the Slim homepage"]
                ]
              ]
            ]
          ]
        end
      end

      context "you can use text interpolation in the quoted attributes" do
        # Expected differences: #1, #2
        let(:template) { <<~'SLIM' }
          - url='slim-lang.com'
          a href="http://#{url}" Goto the #{url}
          a href="{"test"}" Test of quoted text in braces
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [:slim, :control, "url='slim-lang.com'", [:multi, [:newline]]],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, 'http://#{url}']]]
              ],
              [
                :slim, :text, :inline,
                [
                  :multi,
                  [:slim, :interpolate, 'Goto the #{url}']
                ]
              ]
            ],
            [:newline],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, '{"test"}']]],
              ],
              [
                :slim, :text, :inline,
                [
                  :multi,
                  [:slim, :interpolate, "Test of quoted text in braces"]
                ]
              ]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [:slim, :control, [:multi, [:code, "url='slim-lang.com'"]], [:multi]],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, 'http://#{url}']]]
              ],
              [
                :slim, :text, :inline,
                [
                  :multi,
                  [:slim, :interpolate, 'Goto the #{url}']
                ]
              ]
            ],
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, '{"test"}']]],
              ],
              [
                :slim, :text, :inline,
                [
                  :multi,
                  [:slim, :interpolate, "Test of quoted text in braces"]
                ]
              ]
            ]
          ]
        end
      end

      context "attribute values will be escaped by default" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          li
            a href='&' Link
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "li",
              [:html, :attrs],
              [
                :multi,
                [:newline],
                [
                  :html, :tag, "a",
                  [
                    :html, :attrs,
                    [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "&"]]]
                  ],
                  [
                    :slim, :text, :inline,
                    [
                      :multi,
                      [:slim, :interpolate, "Link"]
                    ]
                  ]
                ],
                [:newline]
              ]
            ]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "li",
              [:html, :attrs],
              [
                :multi,
                [
                  :html, :tag, "a",
                  [
                    :html, :attrs,
                    [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "&"]]]
                  ],
                  [
                    :slim, :text, :inline,
                    [
                      :multi,
                      [:slim, :interpolate, "Link"]
                    ]
                  ]
                ]
              ]
            ]
          ]
        end
      end

      context "use `==` if you want to disable attribute escaping" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          li
            a href=='&amp;' Link
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "li",
              [:html, :attrs],
              [
                :multi,
                [:newline],
                [
                  :html, :tag, "a",
                  [
                    :html, :attrs,
                    [:html, :attr, "href", [:escape, false, [:slim, :interpolate, "&amp;"]]]
                  ],
                  [
                    :slim, :text, :inline,
                    [
                      :multi,
                      [:slim, :interpolate, "Link"]
                    ]
                  ]
                ],
                [:newline]
              ]
            ]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "li",
              [:html, :attrs],
              [
                :multi,
                [
                  :html, :tag, "a",
                  [
                    :html, :attrs,
                    [:html, :attr, "href", [:escape, false, [:slim, :interpolate, "&amp;"]]]
                  ],
                  [
                    :slim, :text, :inline,
                    [
                      :multi,
                      [:slim, :interpolate, "Link"]
                    ]
                  ]
                ]
              ]
            ]
          ]
        end
      end

      context "you can use newlines in quoted attributes" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          a data-title="help" data-content="extremely long help text that goes on
            and on and on and then starts over...." Link
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "data-title", [:escape, true, [:slim, :interpolate, "help"]]],
                [
                  :html, :attr, "data-content",
                  [
                    :escape, true,
                    [:slim, :interpolate, "extremely long help text that goes on\nand on and on and then starts over...."]
                  ]
                ]
              ],
              [
                :slim, :text, :inline,
                [
                  :multi,
                  [:slim, :interpolate, "Link"]
                ]
              ]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "data-title", [:escape, true, [:slim, :interpolate, "help"]]],
                [
                  :html, :attr, "data-content",
                  [
                    :escape, true,
                    [:slim, :interpolate, "extremely long help text that goes on\nand on and on and then starts over...."]
                  ]
                ]
              ],
              [
                :slim, :text, :inline,
                [
                  :multi,
                  [:slim, :interpolate, "Link"]
                ]
              ]
            ]
          ]
        end
      end

      context "you can use a backslash before a newline in quoted attributes" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          a data-title="help" data-content="extremely long help text that goes on\
            and on and on and then starts over...." Link
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "data-title", [:escape, true, [:slim, :interpolate, "help"]]],
                [
                  :html, :attr, "data-content",
                  [
                    :escape, true,
                    [:slim, :interpolate, "extremely long help text that goes on and on and on and then starts over...."]
                  ]
                ]
              ],
              [
                :slim, :text, :inline,
                [
                  :multi,
                  [:slim, :interpolate, "Link"]
                ]
              ]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "data-title", [:escape, true, [:slim, :interpolate, "help"]]],
                [
                  :html, :attr, "data-content",
                  [
                    :escape, true,
                    [:slim, :interpolate, "extremely long help text that goes on and on and on and then starts over...."]
                  ]
                ]
              ],
              [
                :slim, :text, :inline,
                [
                  :multi,
                  [:slim, :interpolate, "Link"]
                ]
              ]
            ]
          ]
        end
      end

      context "long Ruby attributes can be broken across lines with a backslash" do
        # Expected differences: #1, #5
        let(:template) { <<~'SLIM' }
          a href=1+\
            1 Link
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [
                  :html, :attr, "href",
                  [:slim, :attrvalue, true, "1+\\\n1"]
                ]
              ],
              [
                :slim, :text, :inline,
                [
                  :multi,
                  [:slim, :interpolate, "Link"]
                ]
              ]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [
                  :html, :attr, "href",
                  [:slim, :attrvalue, true, [:multi, [:code, "1+\\"], [:code, "1"]]]
                ]
              ],
              [
                :slim, :text, :inline,
                [
                  :multi,
                  [:slim, :interpolate, "Link"]
                ]
              ]
            ]
          ]
        end
      end

      context "long Ruby attributes can be broken across lines if the line ends with a comma" do
        # Expected differences: #1, #3, #5
        let(:template) { <<~'SLIM' }
          a href=test('arg1',
                      'arg2',
                      'arg3') Link
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [
                  :html, :attr, "href",
                  [:slim, :attrvalue, true, "test('arg1',\n'arg2',\n'arg3')"]
                ]
              ],
              [
                :slim, :text, :inline,
                [
                  :multi,
                  [:slim, :interpolate, "Link"]
                ]
              ]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [
                  :html, :attr, "href",
                  [
                    :slim, :attrvalue, true,
                    [
                      :multi,
                      [:code, "test('arg1',"],
                      [:code, "     'arg2',"],
                      [:code, "     'arg3')"]
                    ]
                  ]
                ]
              ],
              [
                :slim, :text, :inline,
                [
                  :multi,
                  [:slim, :interpolate, "Link"]
                ]
              ]
            ]
          ]
        end
      end

      context "attribute values `true`, `false` and `nil` are interpreted as booleans" do
        # Expected differences: #1, #5
        let(:template) { <<~'SLIM' }
          input type="text" disabled=variable
          input type="text"
          input type="text" disabled=true
          input type="text" disabled=false
          input type="text" disabled=nil
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "input",
              [
                :html, :attrs,
                [:html, :attr, "type", [:escape, true, [:slim, :interpolate, "text"]]],
                [:html, :attr, "disabled", [:slim, :attrvalue, true, "variable"]]
              ],
              [:multi, [:newline]]
            ],
            [
              :html, :tag, "input",
              [
                :html, :attrs,
                [:html, :attr, "type", [:escape, true, [:slim, :interpolate, "text"]]],
              ],
              [:multi, [:newline]]
            ],
            [
              :html, :tag, "input",
              [
                :html, :attrs,
                [:html, :attr, "type", [:escape, true, [:slim, :interpolate, "text"]]],
                [:html, :attr, "disabled", [:slim, :attrvalue, true, "true"]]
              ],
              [:multi, [:newline]]
            ],
            [
              :html, :tag, "input",
              [
                :html, :attrs,
                [:html, :attr, "type", [:escape, true, [:slim, :interpolate, "text"]]],
                [:html, :attr, "disabled", [:slim, :attrvalue, true, "false"]]
              ],
              [:multi, [:newline]]
            ],
            [
              :html, :tag, "input",
              [
                :html, :attrs,
                [:html, :attr, "type", [:escape, true, [:slim, :interpolate, "text"]]],
                [:html, :attr, "disabled", [:slim, :attrvalue, true, "nil"]]
              ],
              [:multi, [:newline]]
            ],
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "input",
              [
                :html, :attrs,
                [:html, :attr, "type", [:escape, true, [:slim, :interpolate, "text"]]],
                [:html, :attr, "disabled", [:slim, :attrvalue, true, [:multi, [:code, "variable"]]]]
              ],
              [:multi]
            ],
            [
              :html, :tag, "input",
              [
                :html, :attrs,
                [:html, :attr, "type", [:escape, true, [:slim, :interpolate, "text"]]],
              ],
              [:multi]
            ],
            [
              :html, :tag, "input",
              [
                :html, :attrs,
                [:html, :attr, "type", [:escape, true, [:slim, :interpolate, "text"]]],
                [:html, :attr, "disabled", [:slim, :attrvalue, true, [:multi, [:code, "true"]]]]
              ],
              [:multi]
            ],
            [
              :html, :tag, "input",
              [
                :html, :attrs,
                [:html, :attr, "type", [:escape, true, [:slim, :interpolate, "text"]]],
                [:html, :attr, "disabled", [:slim, :attrvalue, true, [:multi, [:code, "false"]]]]
              ],
              [:multi]
            ],
            [
              :html, :tag, "input",
              [
                :html, :attrs,
                [:html, :attr, "type", [:escape, true, [:slim, :interpolate, "text"]]],
                [:html, :attr, "disabled", [:slim, :attrvalue, true, [:multi, [:code, "nil"]]]]
              ],
              [:multi]
            ],
          ]
        end
      end

      context "boolean attribute values can omit the assignment if they are wrapped" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          input(type="text" disabled)
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "input",
              [
                :html, :attrs,
                [:html, :attr, "type", [:escape, true, [:slim, :interpolate, "text"]]],
                [:html, :attr, "disabled", [:multi]]
              ],
              [:multi, [:newline]]
            ]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "input",
              [
                :html, :attrs,
                [:html, :attr, "type", [:escape, true, [:slim, :interpolate, "text"]]],
                [:html, :attr, "disabled", [:multi]]
              ],
              [:multi]
            ]
          ]
        end
      end

      context "some attributes can be automatically merged" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          a.menu class="highlight" href="http://slim-lang.com/" Slim-lang.com
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "class", [:static, "menu"]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "highlight"]]],
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "http://slim-lang.com/"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Slim-lang.com"]]]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "a",
              [
                :html, :attrs,
                [:html, :attr, "class", [:static, "menu"]],
                [:html, :attr, "class", [:escape, true, [:slim, :interpolate, "highlight"]]],
                [:html, :attr, "href", [:escape, true, [:slim, :interpolate, "http://slim-lang.com/"]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Slim-lang.com"]]]
            ]
          ]
        end
      end

      context "arrays are automatically merged as well" do
        # Expected differences: #1, #4
        let(:template) { <<~'SLIM' }
          span class=["first","highlight"] class=classes First
          span class=:second,:highlight class=classes Second
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "span",
              [
                :html, :attrs,
                [:html, :attr, "class", [:slim, :attrvalue, true, '["first","highlight"]']],
                [:html, :attr, "class", [:slim, :attrvalue, true, "classes"]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "First"]]]
            ],
            [:newline],
            [
              :html, :tag, "span",
              [
                :html, :attrs,
                [:html, :attr, "class", [:slim, :attrvalue, true, ":second,:highlight"]],
                [:html, :attr, "class", [:slim, :attrvalue, true, "classes"]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Second"]]]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "span",
              [
                :html, :attrs,
                [:html, :attr, "class", [:slim, :attrvalue, true, [:multi, [:code, '["first","highlight"]']]]],
                [:html, :attr, "class", [:slim, :attrvalue, true, [:multi, [:code, "classes"]]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "First"]]]
            ],
            [
              :html, :tag, "span",
              [
                :html, :attrs,
                [:html, :attr, "class", [:slim, :attrvalue, true, [:multi, [:code, ":second,:highlight"]]]],
                [:html, :attr, "class", [:slim, :attrvalue, true, [:multi, [:code, "classes"]]]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Second"]]]
            ],
          ]
        end
      end

      context "dynamic tags can be created using an attribute splat" do
        # Expected differences: #1, #4
        let(:template) { <<~'SLIM' }
          *link_unless_current Link
          *link_with_params(1, 2) Link
          *link_with_params(1,
             2) Link
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, "*",
              [:html, :attrs, [:slim, :splat, "link_unless_current"]],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link"]]]
            ],
            [:newline],
            [
              :html, :tag, "*",
              [:html, :attrs, [:slim, :splat, "link_with_params(1, 2)"]],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link"]]]
            ],
            [:newline],
            [
              :html, :tag, "*",
              [:html, :attrs, [:slim, :splat, "link_with_params(1,\n2)"]],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link"]]]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, "*",
              [:html, :attrs, [:slim, :splat, [:multi, [:code, "link_unless_current"]]]],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link"]]]
            ],
            [
              :html, :tag, "*",
              [:html, :attrs, [:slim, :splat, [:multi, [:code, "link_with_params(1, 2)"]]]],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link"]]]
            ],
            [
              :html, :tag, "*",
              [
                :html, :attrs,
                [
                  :slim, :splat,
                  [
                    :multi,
                    [:code, "link_with_params(1,"],
                    [:code, "  2)"]
                  ]
                ]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Link"]]]
            ]
          ]
        end
      end
    end

    context "with shorthand" do
      context "ID and class shorthand can contain dashes, slashes with digits, and colons" do
        # Expected differences: #1
        let(:template) { <<~'SLIM' }
          .-test text
          #test- text
          .--a#b- text
          .a--test-123#--b text
          .a-1/2#b-1/2 text
          .ab:c-test#d:e text
        SLIM

        it do
          should officially_parse_as [
            :multi,
            [
              :html, :tag, ".",
              [:html, :attrs, [:html, :attr, "class", [:static, "-test"]]],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "text"]]]
            ],
            [:newline],
            [
              :html, :tag, "#",
              [:html, :attrs, [:html, :attr, "id", [:static, "test-"]]],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "text"]]]
            ],
            [:newline],
            [
              :html, :tag, ".",
              [
                :html, :attrs,
                [:html, :attr, "class", [:static, "--a"]],
                [:html, :attr, "id", [:static, "b-"]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "text"]]]
            ],
            [:newline],
            [
              :html, :tag, ".",
              [
                :html, :attrs,
                [:html, :attr, "class", [:static, "a--test-123"]],
                [:html, :attr, "id", [:static, "--b"]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "text"]]]
            ],
            [:newline],
            [
              :html, :tag, ".",
              [
                :html, :attrs,
                [:html, :attr, "class", [:static, "a-1/2"]],
                [:html, :attr, "id", [:static, "b-1/2"]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "text"]]]
            ],
            [:newline],
            [
              :html, :tag, ".",
              [
                :html, :attrs,
                [:html, :attr, "class", [:static, "ab:c-test"]],
                [:html, :attr, "id", [:static, "d:e"]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "text"]]]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [
              :html, :tag, ".",
              [:html, :attrs, [:html, :attr, "class", [:static, "-test"]]],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "text"]]]
            ],
            [
              :html, :tag, "#",
              [:html, :attrs, [:html, :attr, "id", [:static, "test-"]]],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "text"]]]
            ],
            [
              :html, :tag, ".",
              [
                :html, :attrs,
                [:html, :attr, "class", [:static, "--a"]],
                [:html, :attr, "id", [:static, "b-"]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "text"]]]
            ],
            [
              :html, :tag, ".",
              [
                :html, :attrs,
                [:html, :attr, "class", [:static, "a--test-123"]],
                [:html, :attr, "id", [:static, "--b"]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "text"]]]
            ],
            [
              :html, :tag, ".",
              [
                :html, :attrs,
                [:html, :attr, "class", [:static, "a-1/2"]],
                [:html, :attr, "id", [:static, "b-1/2"]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "text"]]]
            ],
            [
              :html, :tag, ".",
              [
                :html, :attrs,
                [:html, :attr, "class", [:static, "ab:c-test"]],
                [:html, :attr, "id", [:static, "d:e"]]
              ],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, "text"]]]
            ]
          ]
        end
      end
    end
  end

  context "with interpolation" do
    context "tags can use standard Ruby interpolation" do
      # Expected differences: #1, #2
      let(:template) { <<~'SLIM' }
        - user="John Doe <john@doe.net>"
        h1 Welcome #{user}!
      SLIM

        it do
          should officially_parse_as [
            :multi,
            [:slim, :control, "user=\"John Doe <john@doe.net>\"", [:multi, [:newline]]],
            [
              :html, :tag, "h1",
              [:html, :attrs],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, 'Welcome #{user}!']]]
            ],
            [:newline]
          ]
        end

        it do
          should parse_as [
            :multi,
            [:slim, :control, [:multi, [:code, 'user="John Doe <john@doe.net>"']], [:multi]],
            [
              :html, :tag, "h1",
              [:html, :attrs],
              [:slim, :text, :inline, [:multi, [:slim, :interpolate, 'Welcome #{user}!']]]
            ]
          ]
        end
    end
  end
end

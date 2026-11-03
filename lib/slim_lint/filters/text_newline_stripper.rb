# frozen_string_literal: true

module SlimLint::Filters
  # Removes the line breaks from static text. Slim already marks each line of
  # a text block with a [:newline], so once Temple's StaticMerger joins the
  # text, {InjectLineNumbers} would count those lines twice. The text itself
  # doesn't matter: {RubyExtractor} replaces it with a placeholder.
  class TextNewlineStripper < Temple::Filter
    def on_static(text)
      [:static, text.delete("\n")]
    end
  end
end

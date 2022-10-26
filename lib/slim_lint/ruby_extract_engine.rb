# frozen_string_literal: true

module SlimLint
  # Generates a {SlimLint::Sexp} suitable for consumption by the
  # {RubyExtractor}.
  #
  # This is mostly copied from Slim::Engine, with some filters and generators
  # omitted.
  class RubyExtractEngine < Temple::Engine
    filter :Encoding
    filter :RemoveBOM

    # Parse into S-expression using Slim parser
    use SlimLint::Parser

    # Perform additional processing so extracting Ruby code in {RubyExtractor}
    # is easier. We don't do this for regular linters because some information
    # about the original syntax tree is lost in the process, but that doesn't
    # matter in this case.
    use SlimLint::Filters::Interpolation
    use SlimLint::Filters::SplatProcessor
    use SlimLint::Filters::DoInserter
    use SlimLint::Filters::EndInserter
    use SlimLint::Filters::AutoIndenter
    use SlimLint::Filters::ControlProcessor
    use SlimLint::Filters::AttributeProcessor
    use SlimLint::Filters::MultiFlattener
    use SlimLint::Filters::StaticMerger
  end
end

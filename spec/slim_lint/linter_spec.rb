# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter do
  let(:linter_class) do
    Class.new(described_class) do
      on [:lint] do |sexp|
        report_lint(sexp, 'A lint!')
      end
    end
  end

  let(:config) { double }
  let(:linter) { linter_class.new(config) }

  describe '#run' do
    let(:sexp) { [:one, [:lint], :two, [:lint]] }
    let(:document) { double(sexp: SlimLint::Sexp.new(sexp), file: 'file.slim', source_lines: []) }
    subject { linter.run(document) }

    it 'returns the reported lints' do
      subject.length.should == 2
    end

    context 'when a linter calls parse_ruby' do
      let(:linter_class) do
        Class.new(described_class) do
          attr_reader :parsed_ruby

          on [:ruby] do |sexp|
            _, ruby = sexp
            @parsed_ruby = parse_ruby(ruby)
          end
        end
      end

      let(:sexp) { [:ruby, "puts 'Hello world'".dup] }

      it 'parses the ruby' do
        subject
        linter.parsed_ruby.type.should == :send
      end
    end
  end

  describe '#run' do
    context 'when a linter reports a lint with a correction' do
      let(:linter_class) do
        Class.new(described_class) do
          on [:lint] do |sexp|
            report_lint(sexp, 'A lint!', correction: lambda(&:rstrip))
          end
        end
      end

      let(:sexp) { [:lint] }
      let(:document) { double(sexp: SlimLint::Sexp.new(sexp), file: 'file.slim', source_lines: []) }

      it 'stores the correction on the reported lint' do
        lints = linter.run(document)
        lints.first.correctable?.should == true
      end
    end
  end

  describe '.supports_autocorrect?' do
    context 'when the linter has not declared autocorrect support' do
      it { linter_class.supports_autocorrect?.should == false }
    end

    context 'when the linter declares autocorrect support' do
      let(:linter_class) do
        Class.new(described_class) do
          support_autocorrect

          on [:lint] do |sexp|
            report_lint(sexp, 'A lint!')
          end
        end
      end

      it { linter_class.supports_autocorrect?.should == true }
    end
  end

  describe '#name' do
    subject { linter.name }

    before do
      linter.class.stub(:name).and_return('SlimLint::Linter::SomeLinterName')
    end

    it { should == 'SomeLinterName' }
  end
end

# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Linter do
  let(:linter_class) do
    Class.new(described_class) do
      on [:lint] do |sexp|
        report_lint(sexp, "A lint!")
      end
    end
  end

  let(:config) { double }
  let(:linter) { linter_class.new(config) }

  describe "#run" do
    let(:sexp) { [:one, [:lint], :two, [:lint]] }
    let(:document) { double(sexp: SlimLint::Sexp.new(*sexp, start: [1, 1], finish: [2, 3]), file: "file.slim", source_lines: []) }
    subject { linter.run(document) }

    it "returns the reported lints" do
      subject.length.should eq(2)
    end

    context "when a linter calls parse_ruby" do
      let(:linter_class) do
        Class.new(described_class) do
          attr_reader :parsed_ruby

          on [:ruby] do |sexp|
            _, ruby = sexp
            @parsed_ruby = parse_ruby(ruby)
          end
        end
      end

      let(:sexp) { [:ruby, +"puts 'Hello world'"] }

      it "parses the ruby" do
        subject
        linter.parsed_ruby.type.should eq(:send)
      end
    end
  end

  describe "#name" do
    subject { linter.name }

    before do
      linter.class.stub(:name).and_return("SlimLint::Linter::SomeLinterName")
    end

    it { should eq("SomeLinterName") }
  end
end

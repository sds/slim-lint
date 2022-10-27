# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Document do
  let(:config) { double }

  before do
    config.stub(:[]).with("skip_frontmatter").and_return(false)
  end

  describe "#initialize" do
    let(:source) { <<~SLIM }
      doctype html
      head
        title My title
      body
        p My paragraph
    SLIM

    let(:options) { {config: config} }

    subject { described_class.new(source, options) }

    it "stores an S-expression representing the parsed document" do
      subject.sexp.match?([:multi, [:html, :doctype]]).should eq(true)
    end

    it "stores an S-expression with line information" do
      subject.sexp.line.should eq(1)
    end

    it "stores the source code" do
      subject.source.should eq(source)
    end

    it "stores the individual lines of source code" do
      subject.source_lines.should eq(source.split("\n"))
    end

    context "when file is explicitly specified" do
      let(:options) { super().merge(file: "my_file.slim") }

      it "sets the file name" do
        subject.file.should eq("my_file.slim")
      end
    end

    context "when file is not specified" do
      it "returns `nil` for the file name" do
        subject.file.should be_nil
      end
    end

    context "when skip_frontmatter is specified in config" do
      before do
        config.stub(:[]).with("skip_frontmatter").and_return(true)
      end

      context "and the source contains frontmatter" do
        let(:source) { "---\nsome frontmatter\n---\n#{super()}" }

        it "removes the frontmatter" do
          subject.source.should_not include "---"
          subject.source.should include "doctype html"
        end
      end

      context "and the source does not contain frontmatter" do
        it "leaves the source untouched" do
          subject.source.should eq(source)
        end
      end
    end
  end
end

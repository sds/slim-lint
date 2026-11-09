# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::TagCase do
  include_context 'linter'

  context 'when a tag is all lowercase' do
    let(:slim) { 'img src="images/cat.gif"' }

    it { should_not report_lint }
  end

  context 'when a tag contains uppercase characters' do
    let(:slim) { 'IMG src="images/cat.gif"' }

    it { should report_lint line: 1 }
  end

  context 'when the document has an XML doctype' do
    let(:slim) { "doctype xml\nrss\n  channel\n    pubDate Mon, 01 Jan 2024\n" }

    it { should_not report_lint }
  end

  context 'when the XML doctype declares an encoding' do
    let(:slim) { "doctype xml ISO-8859-1\nrss\n  channel\n    lastBuildDate Mon, 01 Jan 2024\n" }

    it { should_not report_lint }
  end

  context 'when the XML doctype is written in uppercase' do
    let(:slim) { "doctype XML\nrss\n  channel\n    pubDate Mon, 01 Jan 2024\n" }

    it { should_not report_lint }
  end

  context 'when an XHTML document declares an XML prolog' do
    let(:slim) { "doctype xml\ndoctype strict\nhtml\n  BODY\n" }

    it { should report_lint line: 4 }
  end

  context 'when the document has an HTML doctype' do
    let(:slim) { "doctype html\nhtml\n  BODY\n" }

    it { should report_lint line: 3 }
  end

  context 'when the doctype only starts with the letters xml' do
    let(:slim) { "doctype xmlish\nIMG src=\"images/cat.gif\"\n" }

    it { should report_lint line: 2 }
  end

  context 'autocorrect support' do
    let(:slim) { '' }

    it 'is declared' do
      described_class.supports_autocorrect?.should == true
    end
  end

  describe 'correction' do
    let(:slim) { 'IMG src="images/cat.gif"' }
    let(:corrector) do
      SlimLint::Corrector.new(SlimLint::Document.new(slim, config: config))
    end

    it 'downcases the offending tag name' do
      subject.lints.first.correction.call('IMG src="images/cat.gif"')
             .should == 'img src="images/cat.gif"'
    end

    context 'when indented' do
      let(:slim) { "tag\n  IMG src=\"images/cat.gif\"\n" }

      it 'only downcases the tag name, preserving indentation' do
        subject.lints.first.correction.call('  IMG src="images/cat.gif"')
               .should == '  img src="images/cat.gif"'
      end
    end

    [
      'div title="IMG": IMG src="cat.png"',
      'div IMG="keep": IMG src="cat.png"',
      'a.IMG: IMG',
      'DIV: DIV',
    ].each do |source|
      context "with an ambiguous tag in #{source.inspect}" do
        let(:slim) { source }

        it 'reports the lint without rewriting the line' do
          expect(subject.lints).not_to be_empty
          expect(corrector.correct(subject.lints)).to eq(slim)
          expect(subject.lints.map(&:corrected?)).to all(eq(false))
        end
      end
    end

    context 'with an unambiguous inline tag' do
      let(:slim) { 'div title="MY_IMG": IMG src="cat.png"' }

      it 'corrects the tag without changing the attribute' do
        expect(corrector.correct(subject.lints)).to eq('div title="MY_IMG": img src="cat.png"')
        expect(subject.lints.first).to be_corrected
      end
    end

    context 'with safe and ambiguous corrections on the same line' do
      let(:slim) { 'DIV title="IMG": IMG src="cat.png"' }

      it 'corrects only the unambiguous tag' do
        expect(corrector.correct(subject.lints)).to eq('div title="IMG": IMG src="cat.png"')
        expect(subject.lints.map(&:corrected?)).to eq([true, false])
      end
    end
  end
end

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
  end
end

require 'spec_helper'

describe SlimLint::RubyExtractor do
  describe '#extract' do
    let(:sexp) { SlimLint::RubyExtractEngine.new.call(normalize_indent(slim)) }
    subject { super().extract(sexp) }

    context 'with an empty Slim document' do
      let(:slim) { '' }
      it { should == '' }
    end

    context 'with verbatim text' do
      let(:slim) { <<-SLIM }
        | Hello world
      SLIM

      it { should == 'puts' }
    end

    context 'with verbatim text on multiple lines' do
      let(:slim) { <<-SLIM }
        |
          Hello
          world
      SLIM

      it { should == 'puts' }
    end

    context 'with verbatim text with trailing whitespace' do
      let(:slim) { <<-SLIM }
        ' Hello world
      SLIM

      it { should == 'puts' }
    end

    context 'with inline HTML' do
      let(:slim) { <<-SLIM }
        <p><b>Hello world!</b></p>
      SLIM

      it { should == 'puts' }
    end

    context 'with control code' do
      let(:slim) { <<-SLIM }
        - some_expression
      SLIM

      it { should == 'some_expression' }
    end

    context 'with output code' do
      let(:slim) { <<-SLIM }
        = some_expression
      SLIM

      it { should == 'some_expression' }
    end

    context 'with output without escaping' do
      let(:slim) { <<-SLIM }
        == some_expression
      SLIM

      it { should == 'some_expression' }
    end

    context 'with a code comment' do
      let(:slim) { <<-SLIM }
        / This line will not appear
      SLIM

      it { should == '' }
    end

    context 'with an HTML comment' do
      let(:slim) { <<-SLIM }
        /! This line will appear
      SLIM

      it { should == 'puts' }
    end

    context 'with an Internet Explorer conditional comment' do
      let(:slim) { <<-SLIM }
        /[if IE]
          Get a better browser
      SLIM

      it { should == "puts\nputs" }
    end

    context 'with doctype tag' do
      let(:slim) { <<-SLIM }
        doctype xml
      SLIM

      it { should == 'puts' }
    end

    context 'with an HTML tag' do
      let(:slim) { <<-SLIM }
        p A paragraph
      SLIM

      it { should == "puts\nputs" }
    end

    context 'with an HTML tag with interpolation' do
      let(:slim) { <<-SLIM }
        p A \#{adjective} paragraph for \#{noun}
      SLIM

      it { should == "puts\nputs\nadjective\nputs\nnoun" }
    end

    context 'with an HTML tag with static attributes' do
      let(:slim) { <<-SLIM }
        p class="highlight"
      SLIM

      it { should == "puts\nputs" }
    end

    context 'with an HTML tag with Ruby attributes' do
      let(:slim) { <<-SLIM }
        p class=user.class id=user.id
      SLIM

      it { should include 'puts' }
      it { should include 'user.class' }
      it { should include 'user.id' }
    end

    context 'with a dynamic tag splat' do
      let(:slim) { <<-SLIM }
        *some_dynamic_tag Hello World!
      SLIM

      # Splatting injects some Slim helper code, so we need to relax the test
      it { should include 'some_dynamic_tag' }
      it { should include 'puts' }
    end

    context 'with an if statement' do
      let(:slim) { <<-SLIM }
        - if condition_true?
          | It's true!
      SLIM

      it { should == normalize_indent(<<-RUBY).chomp }
        if condition_true?
        puts
        end
      RUBY
    end

    context 'with an if/else statement' do
      let(:slim) { <<-SLIM }
        - if condition_true?
          | It's true!
        - else
          | It's false!
      SLIM

      it { should == normalize_indent(<<-RUBY).chomp }
        if condition_true?
        puts
        else
        puts
        end
      RUBY
    end

    context 'with an if/elsif/else statement' do
      let(:slim) { <<-SLIM }
        - if condition_true?
          | It's true!
        - elsif something_else?
          | ???
        - else
          | It's false!
      SLIM

      it { should == normalize_indent(<<-RUBY).chomp }
        if condition_true?
        puts
        elsif something_else?
        puts
        else
        puts
        end
      RUBY
    end
  end
end

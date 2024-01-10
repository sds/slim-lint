# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::ControlStatementSpacing do
  include_context 'linter'

  context 'element missing space before =' do
    let(:slim) { 'div= bad' }

    it { should report_lint }
  end

  context 'element missing space after =' do
    let(:slim) { 'div =bad' }

    it { should report_lint }
  end

  context 'element missing space around =' do
    let(:slim) { 'div=bad' }

    it { should report_lint }
  end

  context 'element too much space before =' do
    let(:slim) { 'div  =bad' }

    it { should report_lint }
  end

  context 'element too much space after =' do
    let(:slim) { 'div=  bad' }

    it { should report_lint }
  end

  context 'id missing space before =' do
    let(:slim) { '#submit= bad' }

    it { should report_lint }
  end

  context 'id missing space after =' do
    let(:slim) { '#submit =bad' }

    it { should report_lint }
  end

  context 'id missing space around =' do
    let(:slim) { '#submit=bad' }

    it { should report_lint }
  end

  context 'id and class missing space around =' do
    let(:slim) { '.some-class#submit=bad' }

    it { should report_lint }
  end

  context 'id too much space before =' do
    let(:slim) { '#submit  =bad' }

    it { should report_lint }
  end

  context 'id too much space after =' do
    let(:slim) { '#submit=  bad' }

    it { should report_lint }
  end

  context 'class missing space before =' do
    let(:slim) { '.klass= bad' }

    it { should report_lint }
  end

  context 'class missing space after =' do
    let(:slim) { '.klass =bad' }

    it { should report_lint }
  end

  context 'class missing space around =' do
    let(:slim) { '.klass=bad' }

    it { should report_lint }
  end

  context 'class too much space before =' do
    let(:slim) { '.klass  =bad' }

    it { should report_lint }
  end

  context 'class too much space after =' do
    let(:slim) { '.klass=  bad' }

    it { should report_lint }
  end

  context 'class with hyphen missing space before =' do
    let(:slim) { '.some-klass= bad' }

    it { should report_lint }
  end

  context 'class with hyphen missing space after =' do
    let(:slim) { '.some-klass =bad' }

    it { should report_lint }
  end

  context 'class with hyphen missing space around =' do
    let(:slim) { '.some-klass=bad' }

    it { should report_lint }
  end

  context 'class with hyphen too much space before =' do
    let(:slim) { '.some-klass  =bad' }

    it { should report_lint }
  end

  context 'class with hyphen too much space after =' do
    let(:slim) { '.some-klass=  bad' }

    it { should report_lint }
  end

  context 'ruby code that contains a properly formatted equal sign' do
    let(:slim) { 'div =bad = 1' }

    it { should report_lint }
  end

  context 'ruby code that contains a properly formatted equal sign' do
    let(:slim) { 'div= bad = 1' }

    it { should report_lint }
  end

  context 'ruby code that contains a properly formatted equal sign' do
    let(:slim) { 'div  = bad = 1' }

    it { should report_lint }
  end

  # OK

  context 'ruby code that contains an equal sign without spacing' do
    let(:slim) { 'div = ok=1' }

    it { should_not report_lint }
  end

  context 'element with hyphen' do
    let(:slim) { 'div - ok' }

    it { should_not report_lint }
  end

  context 'control statement without element' do
    let(:slim) { '= ok' }

    it { should_not report_lint }
  end

  context 'attribute with equal sign without spacing' do
    let(:slim) { 'a href=ok' }

    it { should_not report_lint }
  end

  context 'when an element has a multi-line attribute' do
    # OK
    context 'when it is simple' do
      let(:slim) { <<-'SLIM' }
        div class='one \
          two'
        div = some_method
      SLIM

      it { should_not report_lint }
    end

    context 'when it is more than two lines' do
      let(:slim) { <<-'SLIM' }
        div class='one \
          two three four \
          five six seven \
          eight nine ten eleven twelve'
        div = some_method
      SLIM

      it { should_not report_lint }
    end

    context 'when it has more than two locations' do
      let(:slim) { <<-'SLIM' }
        div class='one \
          two'
        div class='one \
          two three four five six seven \
          eight nine ten eleven twelve'
        div class='one \
          two three four five six seven \
          eight nine ten eleven twelve'
        div = some_method
      SLIM

      it { should_not report_lint }
    end

    # NG
    context 'when it is simple' do
      let(:slim) { <<-'SLIM' }
        div class='one \
          two'
        div= some_method
      SLIM

      it { should report_lint line: 3 }
    end

    context 'when it is more than two lines' do
      let(:slim) { <<-'SLIM' }
        div class='one \
          two three four \
          five six seven \
          eight nine ten eleven twelve'
        div =some_method
      SLIM

      it { should report_lint line: 5 }
    end

    context 'when it has more than two locations' do
      let(:slim) { <<-'SLIM' }
        div class='one \
          two'
        div class='one \
          two three four five six seven \
          eight nine ten eleven twelve'
        div class='one \
          two three four five six seven \
          eight nine ten eleven twelve'
        div=some_method
      SLIM

      it { should report_lint line: 9 }
    end

    context 'when it has more than two locations and verify the correctness of the line count.' do
      let(:slim) { <<-'SLIM' }
        div class='one \
          two'
        div class='one \
          two three four five six seven \
          eight nine ten eleven twelve'
        div=some_method_one
        div class='one \
          two three four five six seven \
          eight nine ten eleven twelve'
        div=some_method_two
      SLIM

      it { should report_lint line: 6 }
      it { should report_lint line: 10 }
    end
  end

  context 'when leading whitespace (=<) is used' do
    context 'and it has appropriate spacing' do
      let(:slim) { 'title =< "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:slim) { 'title=< "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:slim) { 'title =<"Something"' }

      it { should report_lint }
    end
  end

  context 'when trailing whitespace (=>) is used' do
    context 'and it has appropriate spacing' do
      let(:slim) { 'title => "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:slim) { 'title=> "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:slim) { 'title =>"Something"' }

      it { should report_lint }
    end
  end

  context 'when whitespace (=<>) is used' do
    context 'and it has appropriate spacing' do
      let(:slim) { 'title =<> "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:slim) { 'title=<> "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:slim) { 'title =<>"Something"' }

      it { should report_lint }
    end
  end

  context 'when HTML escape disabling (==) is used' do
    context 'and it has appropriate spacing' do
      let(:slim) { 'title == "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:slim) { 'title== "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:slim) { 'title =="Something"' }

      it { should report_lint }
    end
  end

  context 'when HTML escape disabling with leading whitespace (==<) is used' do
    context 'and it has appropriate spacing' do
      let(:slim) { 'title ==< "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:slim) { 'title==< "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:slim) { 'title ==<"Something"' }

      it { should report_lint }
    end
  end

  context 'when HTML escape disabling with trailing whitespace (==>) is used' do
    context 'and it has appropriate spacing' do
      let(:slim) { 'title ==> "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:slim) { 'title==> "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:slim) { 'title ==>"Something"' }

      it { should report_lint }
    end
  end

  context 'when HTML escape disabling with whitespace (==<>) is used' do
    context 'and it has appropriate spacing' do
      let(:slim) { 'title ==<> "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:slim) { 'title==<> "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:slim) { 'title ==<>"Something"' }

      it { should report_lint }
    end
  end
end

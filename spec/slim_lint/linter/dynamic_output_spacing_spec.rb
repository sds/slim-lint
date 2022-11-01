# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Linter::DynamicOutputSpacing do
  include_context "linter"

  context "when enforcing both leading and trailing spaces" do
    let(:config) { {"space_before" => "always", "space_after" => "always"} }

    context "without spaces" do
      let(:slim) { "div=bad" }
      it { should report_lint }
    end

    context "with one space after" do
      let(:slim) { "div= bad" }
      it { should report_lint }
    end

    context "with one space before" do
      let(:slim) { "div =bad" }
      it { should report_lint }
    end

    context "with one space before and after" do
      let(:slim) { "div = bad" }
      it { should_not report_lint }
    end

    context "with multiple before" do
      let(:slim) { "div  = bad" }
      it { should report_lint }
    end

    context "with multiple after" do
      let(:slim) { "div =  bad" }
      it { should report_lint }
    end

    context "with multiple before and after" do
      let(:slim) { "div  =  bad" }
      it { should report_lint }
    end
  end

  context "when enforcing only leading spaces" do
    let(:config) { {"space_before" => "always", "space_after" => "ignore"} }

    context "without spaces" do
      let(:slim) { "div=bad" }
      it { should report_lint }
    end

    context "with one space after" do
      let(:slim) { "div= bad" }
      it { should report_lint }
    end

    context "with one space before" do
      let(:slim) { "div =bad" }
      it { should_not report_lint }
    end

    context "with one space before and after" do
      let(:slim) { "div = bad" }
      it { should_not report_lint }
    end

    context "with multiple before" do
      let(:slim) { "div  =bad" }
      it { should report_lint }
    end

    context "with multiple after" do
      let(:slim) { "div=  bad" }
      it { should report_lint }
    end

    context "with multiple before and after" do
      let(:slim) { "div  =  bad" }
      it { should report_lint }
    end
  end

  context "when enforcing only trailing spaces" do
    let(:config) { {"space_before" => "ignore", "space_after" => "always"} }

    context "without spaces" do
      let(:slim) { "div=bad" }
      it { should report_lint }
    end

    context "with one space after" do
      let(:slim) { "div= bad" }
      it { should_not report_lint }
    end

    context "with one space before" do
      let(:slim) { "div =bad" }
      it { should report_lint }
    end

    context "with one space before and after" do
      let(:slim) { "div = bad" }
      it { should_not report_lint }
    end

    context "with multiple before" do
      let(:slim) { "div  =bad" }
      it { should report_lint }
    end

    context "with multiple after" do
      let(:slim) { "div=  bad" }
      it { should report_lint }
    end

    context "with multiple before and after" do
      let(:slim) { "div  =  bad" }
      it { should report_lint }
    end
  end

  context "when enforcing no leading or trailing spaces" do
    let(:config) { {"space_before" => "never", "space_after" => "never"} }

    context "without spaces" do
      let(:slim) { "div=bad" }
      it { should_not report_lint }
    end

    context "with one space after" do
      let(:slim) { "div= bad" }
      it { should report_lint }
    end

    context "with one space before" do
      let(:slim) { "div =bad" }
      it { should report_lint }
    end

    context "with one space before and after" do
      let(:slim) { "div = bad" }
      it { should report_lint }
    end

    context "with multiple before" do
      let(:slim) { "div  =bad" }
      it { should report_lint }
    end

    context "with multiple after" do
      let(:slim) { "div=  bad" }
      it { should report_lint }
    end

    context "with multiple before and after" do
      let(:slim) { "div  =  bad" }
      it { should report_lint }
    end
  end

  context "when enforcing no leading spaces" do
    let(:config) { {"space_before" => "never", "space_after" => "ignore"} }

    context "without spaces" do
      let(:slim) { "div=bad" }
      it { should_not report_lint }
    end

    context "with one space after" do
      let(:slim) { "div= bad" }
      it { should_not report_lint }
    end

    context "with one space before" do
      let(:slim) { "div =bad" }
      it { should report_lint }
    end

    context "with one space before and after" do
      let(:slim) { "div = bad" }
      it { should report_lint }
    end

    context "with multiple before" do
      let(:slim) { "div  =bad" }
      it { should report_lint }
    end

    context "with multiple after" do
      let(:slim) { "div=  bad" }
      it { should_not report_lint }
    end

    context "with multiple before and after" do
      let(:slim) { "div  =  bad" }
      it { should report_lint }
    end
  end

  context "when enforcing no trailing spaces" do
    let(:config) { {"space_before" => "ignore", "space_after" => "never"} }

    context "without spaces" do
      let(:slim) { "div=bad" }
      it { should_not report_lint }
    end

    context "with one space after" do
      let(:slim) { "div= bad" }
      it { should report_lint }
    end

    context "with one space before" do
      let(:slim) { "div =bad" }
      it { should_not report_lint }
    end

    context "with one space before and after" do
      let(:slim) { "div = bad" }
      it { should report_lint }
    end

    context "with multiple before" do
      let(:slim) { "div  =bad" }
      it { should_not report_lint }
    end

    context "with multiple after" do
      let(:slim) { "div=  bad" }
      it { should report_lint }
    end

    context "with multiple before and after" do
      let(:slim) { "div  =  bad" }
      it { should report_lint }
    end
  end

  # context "id missing space before =" do
  #   let(:slim) { "#submit= bad" }

  #   it { should report_lint }
  # end

  # context "id missing space after =" do
  #   let(:slim) { "#submit =bad" }

  #   it { should report_lint }
  # end

  # context "id missing space around =" do
  #   let(:slim) { "#submit=bad" }

  #   it { should report_lint }
  # end

  # context "id and class missing space around =" do
  #   let(:slim) { ".some-class#submit=bad" }

  #   it { should report_lint }
  # end

  # context "id too much space before =" do
  #   let(:slim) { "#submit  =bad" }

  #   it { should report_lint }
  # end

  # context "id too much space after =" do
  #   let(:slim) { "#submit=  bad" }

  #   it { should report_lint }
  # end

  # context "class missing space before =" do
  #   let(:slim) { ".klass= bad" }

  #   it { should report_lint }
  # end

  # context "class missing space after =" do
  #   let(:slim) { ".klass =bad" }

  #   it { should report_lint }
  # end

  # context "class missing space around =" do
  #   let(:slim) { ".klass=bad" }

  #   it { should report_lint }
  # end

  # context "class too much space before =" do
  #   let(:slim) { ".klass  =bad" }

  #   it { should report_lint }
  # end

  # context "class too much space after =" do
  #   let(:slim) { ".klass=  bad" }

  #   it { should report_lint }
  # end

  # context "class with hyphen missing space before =" do
  #   let(:slim) { ".some-klass= bad" }

  #   it { should report_lint }
  # end

  # context "class with hyphen missing space after =" do
  #   let(:slim) { ".some-klass =bad" }

  #   it { should report_lint }
  # end

  # context "class with hyphen missing space around =" do
  #   let(:slim) { ".some-klass=bad" }

  #   it { should report_lint }
  # end

  # context "class with hyphen too much space before =" do
  #   let(:slim) { ".some-klass  =bad" }

  #   it { should report_lint }
  # end

  # context "class with hyphen too much space after =" do
  #   let(:slim) { ".some-klass=  bad" }

  #   it { should report_lint }
  # end

  # context "ruby code that contains a properly formatted equal sign" do
  #   let(:slim) { "div =bad = 1" }

  #   it { should report_lint }
  # end

  # context "ruby code that contains a properly formatted equal sign" do
  #   let(:slim) { "div= bad = 1" }

  #   it { should report_lint }
  # end

  # context "ruby code that contains a properly formatted equal sign" do
  #   let(:slim) { "div  = bad = 1" }

  #   it { should report_lint }
  # end

  # # OK

  # context "ruby code that contains an equal sign without spacing" do
  #   let(:slim) { "div = ok=1" }

  #   it { should_not report_lint }
  # end

  # context "element with hyphen" do
  #   let(:slim) { "div - ok" }

  #   it { should_not report_lint }
  # end

  # context "control statement without element" do
  #   let(:slim) { "= ok" }

  #   it { should_not report_lint }
  # end

  # context "attribute with equal sign without spacing" do
  #   let(:slim) { "a href=ok" }

  #   it { should_not report_lint }
  # end

  # context "when leading whitespace (=<) is used" do
  #   context "and it has appropriate spacing" do
  #     let(:slim) { 'title =< "Something"' }

  #     it { should_not report_lint }
  #   end

  #   context "and it lacks spacing on the left" do
  #     let(:slim) { 'title=< "Something"' }

  #     it { should report_lint }
  #   end

  #   context "and it lacks spacing on the right" do
  #     let(:slim) { 'title =<"Something"' }

  #     it { should report_lint }
  #   end
  # end

  # context "when trailing whitespace (=>) is used" do
  #   context "and it has appropriate spacing" do
  #     let(:slim) { 'title => "Something"' }

  #     it { should_not report_lint }
  #   end

  #   context "and it lacks spacing on the left" do
  #     let(:slim) { 'title=> "Something"' }

  #     it { should report_lint }
  #   end

  #   context "and it lacks spacing on the right" do
  #     let(:slim) { 'title =>"Something"' }

  #     it { should report_lint }
  #   end
  # end

  # context "when whitespace (=<>) is used" do
  #   context "and it has appropriate spacing" do
  #     let(:slim) { 'title =<> "Something"' }

  #     it { should_not report_lint }
  #   end

  #   context "and it lacks spacing on the left" do
  #     let(:slim) { 'title=<> "Something"' }

  #     it { should report_lint }
  #   end

  #   context "and it lacks spacing on the right" do
  #     let(:slim) { 'title =<>"Something"' }

  #     it { should report_lint }
  #   end
  # end

  # context "when HTML escape disabling (==) is used" do
  #   context "and it has appropriate spacing" do
  #     let(:slim) { 'title == "Something"' }

  #     it { should_not report_lint }
  #   end

  #   context "and it lacks spacing on the left" do
  #     let(:slim) { 'title== "Something"' }

  #     it { should report_lint }
  #   end

  #   context "and it lacks spacing on the right" do
  #     let(:slim) { 'title =="Something"' }

  #     it { should report_lint }
  #   end
  # end

  # context "when HTML escape disabling with leading whitespace (==<) is used" do
  #   context "and it has appropriate spacing" do
  #     let(:slim) { 'title ==< "Something"' }

  #     it { should_not report_lint }
  #   end

  #   context "and it lacks spacing on the left" do
  #     let(:slim) { 'title==< "Something"' }

  #     it { should report_lint }
  #   end

  #   context "and it lacks spacing on the right" do
  #     let(:slim) { 'title ==<"Something"' }

  #     it { should report_lint }
  #   end
  # end

  # context "when HTML escape disabling with trailing whitespace (==>) is used" do
  #   context "and it has appropriate spacing" do
  #     let(:slim) { 'title ==> "Something"' }

  #     it { should_not report_lint }
  #   end

  #   context "and it lacks spacing on the left" do
  #     let(:slim) { 'title==> "Something"' }

  #     it { should report_lint }
  #   end

  #   context "and it lacks spacing on the right" do
  #     let(:slim) { 'title ==>"Something"' }

  #     it { should report_lint }
  #   end
  # end

  # context "when HTML escape disabling with whitespace (==<>) is used" do
  #   context "and it has appropriate spacing" do
  #     let(:slim) { 'title ==<> "Something"' }

  #     it { should_not report_lint }
  #   end

  #   context "and it lacks spacing on the left" do
  #     let(:slim) { 'title==<> "Something"' }

  #     it { should report_lint }
  #   end

  #   context "and it lacks spacing on the right" do
  #     let(:slim) { 'title ==<>"Something"' }

  #     it { should report_lint }
  #   end
  # end
end

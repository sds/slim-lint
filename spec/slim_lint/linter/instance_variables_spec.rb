# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::InstanceVariables do
  include_context 'linter'

  context 'with no instance variables' do
    let(:slim) { <<-SLIM }
      h1 Hello world!
    SLIM

    it { should_not report_lint }
  end

  context 'with instance variables in static contexts only' do
    let(:slim) { <<-SLIM }
      - if "@harmless_variable"
        = "@another_harmless_variable"
      p @and_another
      ' \#{"@and_another"}
    SLIM

    it { should_not report_lint }
  end

  context 'with instance variables in control code' do
    let(:slim) { <<-SLIM }
      - if @world
        ' hello world
      - call(arg: @hello)
    SLIM

    it { should report_lint line: 1 }
    it { should report_lint line: 3 }
  end

  context 'with instance variables in output code' do
    let(:slim) { <<-SLIM }
      p
        ' hello
        = @world
      == call(arg: @hello)
      span = @some_variable
    SLIM

    it { should report_lint line: 3 }
    it { should report_lint line: 4 }
    it { should report_lint line: 5 }
  end

  context 'with instance variables in interpolated code' do
    let(:slim) { <<-SLIM }
      ' \#{@hello}
    SLIM

    it { should report_lint line: 1 }
  end
end

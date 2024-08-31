# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::Tag do
  include_context 'linter'

  context 'when a lowercased tag is contained in forbidden_tags' do
    let(:config) do
      { 'forbidden_tags' => %w[a] }
    end

    let(:slim) { 'a href="/foo"' }

    it { should report_lint line: 1 }
  end

  context 'when an uppercased tag is contained in forbidden_tags' do
    let(:config) do
      { 'forbidden_tags' => %w[a] }
    end

    let(:slim) { 'A href="/foo"' }

    it { should report_lint line: 1 }
  end

  context 'when a tag is not contained in forbidden_tags' do
    let(:config) do
      { 'forbidden_tags' => %w[a] }
    end

    let(:slim) { 'textarea name="foo"' }

    it { should_not report_lint }
  end
end

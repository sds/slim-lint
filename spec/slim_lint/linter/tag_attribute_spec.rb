# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::TagAttribute do
  include_context 'linter'

  context 'when a lowercased attribute is contained in forbidden_attributes' do
    let(:config) do
      { 'forbidden_attributes' => %w[style] }
    end

    let(:slim) { 'p style="{ color: red; }"' }

    it { should report_lint line: 1 }
  end

  context 'when an uppercased attribute is contained in forbidden_attributes' do
    let(:config) do
      { 'forbidden_attributes' => %w[style] }
    end

    let(:slim) { 'P STYLE="{ color: red; }"' }

    it { should report_lint line: 1 }
  end

  context 'when an attribute is not contained in forbidden_attributes' do
    let(:config) do
      { 'forbidden_attributes' => %w[style] }
    end

    let(:slim) { 'style media="all"' }

    it { should_not report_lint }
  end
end

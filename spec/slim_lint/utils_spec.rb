require 'spec_helper'

describe SlimLint::Utils do
  describe '.for_consecutive_items' do
    let(:min_items) { 2 }
    let(:matches_proc) { ->(item) { item } }

    subject do
      described_class.for_consecutive_items(
        items,
        ->(item) { item },
        min_items,
      )
    end

    context 'with an empty list' do
      let(:items) { [] }

      it 'does not yield' do
        expect do |block|
          described_class.for_consecutive_items(items, matches_proc, min_items, &block)
        end.not_to yield_control
      end
    end

    context 'with a list with one item' do
      let(:items) { [false] }

      it 'does not yield' do
        expect do |block|
          described_class.for_consecutive_items(items, matches_proc, min_items, &block)
        end.not_to yield_control
      end
    end

    context 'with a list with no consecutive items' do
      let(:items) { [true, false] }

      it 'does not yield' do
        expect do |block|
          described_class.for_consecutive_items(items, matches_proc, min_items, &block)
        end.not_to yield_control
      end
    end

    context 'with a list with one group of consecutive items' do
      let(:items) { [false, true, true, false] }

      it 'yields the single group' do
        expect do |block|
          described_class.for_consecutive_items(items, matches_proc, min_items, &block)
        end.to yield_successive_args([true, true])
      end

      context 'and the group is under the required minimum size' do
        let(:min_items) { 3 }

        it 'does not yield' do
          expect do |block|
            described_class.for_consecutive_items(items, matches_proc, min_items, &block)
          end.not_to yield_control
        end
      end
    end

    context 'with a list with two groups of consecutive items' do
      let(:items) { [false, true, true, false, true, true, true] }

      it 'yields both groups' do
        expect do |block|
          described_class.for_consecutive_items(items, matches_proc, min_items, &block)
        end.to yield_successive_args([true, true], [true, true, true])
      end

      context 'and one of the groups is under the required minimum size' do
        let(:min_items) { 3 }

        it 'yields only the larger group' do
          expect do |block|
            described_class.for_consecutive_items(items, matches_proc, min_items, &block)
          end.to yield_successive_args([true, true, true])
        end
      end
    end
  end
end

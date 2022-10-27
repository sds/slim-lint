# frozen_string_literal: true

require "spec_helper"

describe SlimLint::Sexp do
  describe "#initialize" do
    subject { described_class.new(*arg, start: [1, 1], finish: [2, 3]) }

    context "when given an empty array" do
      let(:arg) { [] }

      it "creates an empty Sexp" do
        subject.should be_empty
      end
    end

    context "when given a flat array" do
      let(:arg) { [:one, :two, :three] }

      it "creates a flat Sexp" do
        subject.length.should eq(3)
      end
    end

    context "when given a nested array" do
      let(:arg) { [:one, [:two_one, :two_two], [:three_one, :three_two]] }

      it "creates a nested Sexp" do
        subject.length.should eq(3)
        subject[0].should be_a SlimLint::Atom
        subject[1].should be_a SlimLint::Sexp
        subject[1].length.should eq(2)
        subject[2].length.should eq(2)
      end
    end
  end

  describe "#==" do
    subject { sexp == other }

    context "when Sexp is a flat expression" do
      let(:sexp) { described_class.new(:atom, :another_atom, start: [1, 1], finish: [2, 3]) }

      context "and is compared to an equivalent expression" do
        let(:other) { described_class.new(:atom, :another_atom, start: [1, 1], finish: [2, 3]) }

        it { should eq(true) }
      end

      context "and is compared to a non-equivalent expression of equal length" do
        let(:other) { described_class.new(:atom, :something_else, start: [1, 1], finish: [2, 3]) }

        it { should eq(false) }
      end

      context "and is compared to a non-equivalent expression of different length" do
        let(:other) { described_class.new(:atom, :another_atom, :something_else, start: [1, 1], finish: [2, 3]) }

        it { should eq(false) }
      end

      context "and is compared to an atom" do
        let(:other) { SlimLint::Atom.new(:atom, pos: [2, 1]) }

        it { should eq(false) }
      end
    end

    context "when Sexp is a nested expression" do
      let(:sexp) { described_class.new(:one, [:two_one, :two_two], :three, start: [1, 1], finish: [2, 3]) }

      context "and is compared to an equivalent expression" do
        let(:other) { described_class.new(:one, [:two_one, :two_two], :three, start: [1, 1], finish: [2, 3]) }

        it { should eq(true) }
      end

      context "and is compared to a non-equivalent expression of equal length" do
        let(:other) { described_class.new(:one, [:two_one, :mismatch], :three, start: [1, 1], finish: [2, 3]) }

        it { should eq(false) }
      end

      context "and is compared to a non-equivalent expression of different length" do
        let(:other) { described_class.new(:one, [:mismatch], :three, start: [1, 1], finish: [2, 3]) }

        it { should eq(false) }
      end

      context "and is compared to an atom" do
        let(:other) { SlimLint::Atom.new(:atom, pos: [2, 1]) }

        it { should eq(false) }
      end
    end
  end

  describe "#match?" do
    subject { sexp.match?(pattern) }

    context "when Sexp is an expression" do
      let(:sexp) { described_class.new(:one, :two, [:three_one, :three_two], start: [1, 1], finish: [2, 3]) }

      context "and the pattern is an atom" do
        let(:pattern) { :one }

        it { should eq(false) }
      end

      context "and the pattern is a matching prefix of length one" do
        let(:pattern) { [:one] }

        it { should eq(true) }
      end

      context "and the pattern is a matching prefix of length two" do
        let(:pattern) { [:one, :two] }

        it { should eq(true) }
      end

      context "and the pattern is a non-matching prefix" do
        let(:pattern) { [:one, :mismatch] }

        it { should eq(false) }
      end

      context "and the pattern is a matching prefix with nested matches" do
        let(:pattern) { [:one, :two, [:three_one]] }

        it { should eq(true) }
      end

      context "and the pattern is a non-matching prefix with nested mismatches" do
        let(:pattern) { [:one, :two, [:mismatch, :three_two]] }

        it { should eq(false) }
      end

      context "and the pattern is a matching matcher" do
        let(:pattern) { SlimLint::Matcher::Anything.new }

        it { should eq(true) }
      end

      context "and the pattern is a non-matching matcher" do
        let(:pattern) { SlimLint::Matcher::Nothing.new }

        it { should eq(false) }
      end
    end
  end
end

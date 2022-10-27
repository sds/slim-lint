# frozen_string_literal: true

require "spec_helper"

describe SlimLint::SexpVisitor do
  let(:visitor_class) do
    Class.new do
      include SlimLint::SexpVisitor
      extend SlimLint::SexpVisitor::DSL
    end
  end

  let(:visitor) { visitor_class.new }
  subject { visitor }

  describe "#trigger_pattern_callbacks" do
    let(:sexp) { [:one, [:match, :one], [:two, [:match, :two]]] }
    subject { visitor.trigger_pattern_callbacks(SlimLint::Sexp.new(*sexp, start: [1, 1], finish: [3, 1])) }

    context "when on_start block is specified" do
      let(:visitor_class) do
        Class.new(super()) do
          attr_reader :matches, :root_sexp

          on_start do |sexp|
            @root_sexp = sexp
            @matches = []
          end

          on [:match] do |sexp|
            @matches << sexp
          end
        end
      end

      it "runs the on_start block" do
        subject
        visitor.root_sexp.should eq(sexp)
      end

      context "and the block does not return :stop" do
        it "continues traversing" do
          subject
          visitor.matches.count.should eq(2)
        end
      end

      context "and the block returns :stop" do
        let(:visitor_class) do
          Class.new(super()) do
            attr_reader :matches

            on_start do |*|
              @matches = []
              :stop
            end

            on [:match] do |sexp|
              @matches << sexp
            end
          end
        end

        it "stops traversing" do
          subject
          visitor.matches.count.should eq(0)
        end
      end
    end

    context "when on [...] block returns :stop" do
      let(:visitor_class) do
        Class.new(super()) do
          attr_reader :matches

          on [:match] do |sexp|
            @matches ||= []
            @matches << sexp
          end

          on [:stop] do |*|
            :stop
          end
        end
      end

      let(:sexp) do
        [:root,
          [:match, :included],
          [:stop,
            [:match, :ignored]],
          [:match, :included]]
      end

      it "stops further traversal down that branch of the Sexp" do
        subject
        visitor.matches.count.should eq(2)
      end
    end

    context "when on [...] block uses `anything` matcher" do
      let(:visitor_class) do
        Class.new(super()) do
          attr_reader :matches

          on [:match, :almost, anything] do |sexp|
            @matches ||= []
            @matches << sexp
          end
        end
      end

      let(:sexp) do
        [:root,
          [:match, :almost, :one],
          [:match, :ignore, :two],
          [:match, :almost, :three]]
      end

      it "runs the block for all matching Sexps" do
        subject
        visitor.matches.count.should eq(2)
      end
    end

    context "when on [...] block uses `capture` matcher" do
      let(:visitor_class) do
        Class.new(super()) do
          attr_reader :capture_values, :matches

          on [:match, capture(:value, anything)] do |sexp|
            @matches ||= []
            @matches << sexp
            @capture_values ||= []
            @capture_values << captures[:value]
          end
        end
      end

      let(:sexp) do
        [:root,
          [:match, :almost, :one],
          [:match, :again, :two],
          [:match, :another, :three]]
      end

      it "runs the block for all matching Sexps" do
        subject
        visitor.matches.count.should eq(3)
      end

      it "exposes the captured value to each block run" do
        subject
        visitor.capture_values.should eq([:almost, :again, :another])
      end
    end
  end
end

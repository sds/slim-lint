# frozen_string_literal: true

require "spec_helper"
require "slim_lint/rake_task"
require "tempfile"

describe SlimLint::RakeTask do
  before(:all) do
    SlimLint::RakeTask.new do |t|
      t.quiet = true
    end
  end

  let(:file) do
    Tempfile.new("slim_file.slim").tap do |f|
      f.write(slim)
      f.close
    end
  end

  def run_task
    Rake::Task[:slim_lint].tap do |t|
      t.reenable # Allows us to execute task multiple times
      t.invoke(file.path)
    end
  end

  context "when Slim document is valid" do
    let(:slim) { "p Hello world\n" }

    it "executes without error" do
      run_task
      # expect { run_task }.not_to raise_error
    end
  end

  context "when Slim document is invalid" do
    let(:slim) { "%tag" }

    it "raises an error" do
      expect { run_task }.to raise_error RuntimeError
    end
  end
end

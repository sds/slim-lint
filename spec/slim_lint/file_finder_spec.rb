# frozen_string_literal: true

require "spec_helper"

describe SlimLint::FileFinder do
  let(:config) { double }
  let(:excluded_patterns) { [] }

  subject { described_class.new(config) }

  describe "#find" do
    include_context "isolated environment"

    subject { super().find(patterns, excluded_patterns) }

    context "when no patterns are given" do
      let(:patterns) { [] }

      context "and there are no Slim files under the current directory" do
        it { should eq([]) }
      end

      context "and there are Slim files under the current directory" do
        before do
          `touch blah.slim`
          `mkdir -p more`
          `touch more/more.slim`
        end

        it { should eq([]) }
      end
    end

    context "when files without a valid extension are given" do
      let(:patterns) { ["test.txt"] }

      context "and those files exist" do
        before do
          `touch test.txt`
        end

        it { should eq(["test.txt"]) }

        context "and that file is excluded directly" do
          let(:excluded_patterns) { ["test.txt"] }

          it { should eq([]) }
        end

        context "and that file is excluded via glob pattern" do
          let(:excluded_patterns) { ["test.*"] }

          it { should eq([]) }
        end
      end

      context "and those files do not exist" do
        it "raises an error" do
          expect { subject }.to raise_error SlimLint::Exceptions::InvalidFilePath
        end
      end
    end

    context "when directories are given" do
      let(:patterns) { ["some-dir"] }

      context "and those directories exist" do
        before do
          `mkdir -p some-dir`
        end

        context "and they contain Slim files" do
          before do
            `touch some-dir/test.slim`
          end

          it { should eq(["some-dir/test.slim"]) }

          context "and those Slim files are excluded explicitly" do
            let(:excluded_patterns) { ["some-dir/test.slim"] }

            it { should eq([]) }
          end

          context "and those Slim files are excluded via glob" do
            let(:excluded_patterns) { ["some-dir/*"] }

            it { should eq([]) }
          end
        end

        context "and they contain more directories with files with recognized extensions" do
          before do
            `mkdir -p some-dir/more-dir`
            `touch some-dir/more-dir/test.slim`
          end

          it { should eq(["some-dir/more-dir/test.slim"]) }
        end

        context "and they contain files with some other extension" do
          before do
            `touch some-dir/test.txt`
          end

          it { should eq([]) }
        end
      end

      context "and those directories do not exist" do
        it "raises an error" do
          expect { subject }.to raise_error SlimLint::Exceptions::InvalidFilePath
        end
      end

      context "and the directory is the current directory" do
        let(:patterns) { ["."] }

        context "and the directory contains Slim files" do
          before do
            `touch test.slim`
          end

          it { should eq(["test.slim"]) }

          context "and those Slim files are excluded explicitly" do
            let(:excluded_patterns) { ["test.slim"] }

            it { should eq([]) }
          end

          context "and those Slim files are excluded explicitly with leading slash" do
            let(:excluded_patterns) { ["./test.slim"] }

            it { should eq([]) }
          end

          context "and those Slim files are excluded via glob" do
            let(:excluded_patterns) { ["test.*"] }

            it { should eq([]) }
          end
        end

        context "and directory contain files with some other extension" do
          before do
            `touch test.txt`
          end

          it { should eq([]) }
        end
      end
    end

    context "when glob patterns are given" do
      let(:patterns) { ["test*.txt"] }

      context "and no files match the glob pattern" do
        before do
          `touch some-file.txt`
        end

        it "raises a descriptive error" do
          expect { subject }.to raise_error SlimLint::Exceptions::InvalidFilePath
        end
      end

      context "and a file named the same as the glob pattern exists" do
        before do
          `touch 'test*.txt' test1.txt`
        end

        it { should eq(["test*.txt"]) }
      end

      context "and files matching the glob pattern exist" do
        before do
          `touch test1.txt test-some-words.txt`
        end

        it "includes all matching files" do
          should eq(["test-some-words.txt", "test1.txt"])
        end

        context "and a glob pattern excludes a file" do
          let(:excluded_patterns) { ["*some*"] }

          it { should eq(["test1.txt"]) }
        end
      end
    end

    context "when the same file is specified multiple times" do
      let(:patterns) { ["test.slim"] * 3 }

      before do
        `touch test.slim`
      end

      it { should eq(["test.slim"]) }
    end

    context "when an absolute file path is given" do
      let(:patterns) { [File.expand_path("test.slim")] }

      before do
        `touch test.slim`
      end

      context "and a non-absolute exclusion matches the pattern" do
        let(:excluded_patterns) { ["test.slim"] }

        it { should eq([]) }
      end
    end
  end
end

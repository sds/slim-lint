require 'spec_helper'

describe SlimLint::FileFinder do
  let(:config) { double }
  let(:excluded_patterns) { [] }

  subject { described_class.new(config) }

  describe '#find' do
    include_context 'isolated environment'

    subject { super().find(patterns, excluded_patterns) }

    context 'when no patterns are given' do
      let(:patterns) { [] }

      context 'and there are no Slim files under the current directory' do
        it { should == [] }
      end

      context 'and there are Slim files under the current directory' do
        before do
          `touch blah.slim`
          `mkdir -p more`
          `touch more/more.slim`
        end

        it { should == [] }
      end
    end

    context 'when files without a valid extension are given' do
      let(:patterns) { ['test.txt'] }

      context 'and those files exist' do
        before do
          `touch test.txt`
        end

        it { should == ['test.txt'] }
      end

      context 'and those files do not exist' do
        it 'raises an error' do
          expect { subject }.to raise_error SlimLint::Exceptions::InvalidFilePath
        end
      end
    end

    context 'when directories are given' do
      let(:patterns) { ['some-dir'] }

      context 'and those directories exist' do
        before do
          `mkdir -p some-dir`
        end

        context 'and they contain Slim files' do
          before do
            `touch some-dir/test.slim`
          end

          it { should == ['some-dir/test.slim'] }
        end

        context 'and they contain more directories with files with recognized extensions' do
          before do
            `mkdir -p some-dir/more-dir`
            `touch some-dir/more-dir/test.slim`
          end

          it { should == ['some-dir/more-dir/test.slim'] }
        end

        context 'and they contain files with some other extension' do
          before do
            `touch some-dir/test.txt`
          end

          it { should == [] }
        end
      end

      context 'and those directories do not exist' do
        it 'raises an error' do
          expect { subject }.to raise_error SlimLint::Exceptions::InvalidFilePath
        end
      end
    end

    context 'when the same file is specified multiple times' do
      let(:patterns) { ['test.slim'] * 3 }

      before do
        `touch test.slim`
      end

      it { should == ['test.slim'] }
    end
  end
end

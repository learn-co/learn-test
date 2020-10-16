# frozen_string_literal: true

describe LearnTest::Git::Wip::Branch do
  let(:base) { LearnTest::Git::Base.open('./') }
  let(:name) { base.current_branch }
  let(:branch) do
    described_class.new(
      base: base,
      name: name
    )
  end

  let(:sha1) { Digest::SHA1.new.hexdigest }
  let(:nothing_to_commit_error_msg) { 'nothing to commit, working directory clean' }
  let(:no_commits_error_msg) do
    "fatal: ambiguous argument '#{name}': unknown revision or path not in the working tree."
  end

  describe 'accessors' do
    it 'should have :parent, :parent=' do
      expect(branch).to respond_to(:parent, :parent=)
    end
  end

  describe '.new' do
    it 'should require :base' do
      expect { described_class.new(base: {}) }.to raise_error(ArgumentError, /name/)
    end

    it 'should require :name' do
      expect { described_class.new(name: 'foo') }.to raise_error(ArgumentError, /base/)
    end
  end

  describe '.to_s' do
    it 'should return @name' do
      expect(branch.to_s).to eq(name)
    end
  end

  describe '.last_revision' do
    context 'success' do
      it 'should return a SHA' do
        expect(base)
          .to receive(:revparse)
          .with(name)
          .and_return(sha1)

        expect(branch.last_revision).to eq(sha1)
      end

      it 'should only run revparse once' do
        expect(base)
          .to receive(:revparse)
          .with(name)
          .and_return(sha1)
          .once

        expect(branch.last_revision).to eq(sha1)
        expect(branch.last_revision).to eq(sha1)
      end
    end

    context 'hide expected Git errors' do
      it 'should hide no commits error' do
        expect(base)
          .to receive(:revparse)
          .with(name)
          .and_raise(::Git::GitExecuteError, no_commits_error_msg)

        expect { branch.last_revision }.to_not raise_error
      end

      it 'should return false' do
        expect(base)
          .to receive(:revparse)
          .with(name)
          .and_raise(::Git::GitExecuteError, no_commits_error_msg)

        expect(branch.last_revision).to eq(false)
      end
    end

    context 'raise expected Git errors' do
      it 'should raise no commits error' do
        expect(base)
          .to receive(:revparse)
          .with(name)
          .and_raise(::Git::GitExecuteError, no_commits_error_msg)

        expect do
          branch.last_revision(raise_no_commits: true)
        end.to raise_error(
          LearnTest::Git::Wip::Errors::NoCommitsError, "Branch `#{name}` doesn't have any commits. Please commit and try again."
        )
      end
    end

    context 'raise unexpected Git errors' do
      it 'should raise no commits error' do
        expect(base)
          .to receive(:revparse)
          .with(name)
          .and_raise(::Git::GitExecuteError, nothing_to_commit_error_msg)

        expect { branch.last_revision }.to raise_error(::Git::GitExecuteError, nothing_to_commit_error_msg)
      end
    end

    context 'raise unexpected errors' do
      it 'should raise' do
        expect(base)
          .to receive(:revparse)
          .with(name)
          .and_raise(StandardError)

        expect { branch.last_revision }.to raise_error(StandardError)
      end
    end
  end
end

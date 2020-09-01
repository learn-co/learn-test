# frozen_string_literal: true

describe LearnTest::GitWip do
  subject { described_class }

  let!(:working_branch) { 'develop' }
  let!(:git_url) { 'https://github.com/learn-co/learn-test' }
  let!(:git_base) { instance_double(Git::Base) }

  let(:wait_thr) { double }
  let(:wait_thr_value) { double }
  let(:stdout_and_stderr) { double }

  context 'success' do
    it 'should return the git url' do
      expect(Git::Base).to receive(:open).with('./', { log: false }).and_return(git_base)
      expect(git_base).to receive(:current_branch).and_return(working_branch)

      expect(wait_thr).to receive(:value).and_return(wait_thr_value)
      expect(wait_thr_value).to receive(:exitstatus).and_return(0)

      expect(Open3).to receive(:popen3).and_yield(nil, nil, nil, wait_thr)

      expect(git_base).to receive_message_chain(:config, :[]).with('remote.origin.url').and_return("#{git_url}.git")
      expect(subject.run!).to eq("#{git_url}/tree/wip")
    end
  end

  context 'failure' do
    it 'should return false on process error' do
      expect(Git::Base).to receive(:open).with('./', { log: false }).and_return(git_base)
      expect(git_base).to receive(:current_branch).and_return(working_branch)

      expect(wait_thr).to receive(:value).and_return(wait_thr_value)
      expect(wait_thr_value).to receive(:exitstatus).and_return(1)

      expect(Open3).to receive(:popen3).and_yield(nil, nil, nil, wait_thr)

      expect(subject.run!).to eq(false)
    end

    it 'should return false on StandardError' do
      expect(Git::Base).to receive(:open).and_raise(StandardError)
      expect(subject.run!).to eq(false)
    end
  end
end

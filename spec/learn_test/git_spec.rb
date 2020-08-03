describe LearnTest::GitWip do
  subject { described_class }

  let!(:working_branch) { 'develop' }
  let!(:git_url) { 'https://github.com/learn-co/learn-test' }
  let!(:git_base) { instance_double(Git::Base) }

  context 'success' do
    it 'should return the git url' do
      expect(Git::Base).to receive(:open).with('./', { log: false }).and_return(git_base)
      expect(git_base).to receive(:current_branch).and_return(working_branch)

      expect(subject).to receive(:`).with(/learn-test-wip save ".+" -u &> \/dev\/null/ )
      expect($?).to receive(:success?).and_return(true)

      expect(git_base).to receive(:push).with('origin', "wip/#{working_branch}:refs/heads/wip")
      expect(git_base).to receive_message_chain(:config, :[]).with('remote.origin.url').and_return("#{git_url}.git")

      expect(subject.run!).to eq("#{git_url}/tree/wip")
    end
  end

  context 'failure' do
    it 'should return false on process error' do
      allow(Git::Base).to receive(:open).and_return(git_base)
      allow(git_base).to receive(:current_branch)
      allow(subject).to receive(:`)

      expect($?).to receive(:success?).and_return(false)
      expect(subject.run!).to eq(false)
    end

    it 'should return false on StandardError' do
      expect(Git::Base).to receive(:open).and_raise(StandardError)
      expect(subject.run!).to eq(false)
    end
  end
end

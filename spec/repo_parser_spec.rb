# frozen_string_literal: true

require 'spec_helper'
RSpec.describe LearnTest::RepoParser do
  context 'URLs from github' do
    let!(:remote) { OpenStruct.new(url: nil) }
    let!(:repo) { OpenStruct.new(remote: remote) }

    it 'supports ssh addresses' do
      expect(Git).to receive(:open).and_return(repo)
      remote.url = 'git@github.com:flatiron-labs/learn-gem.git'
      expect(described_class.get_repo).to eq('learn-gem')
    end

    it 'supports http addresses' do
      expect(Git).to receive(:open).and_return(repo)
      remote.url = 'https://github.com/flatiron-labs/learn-gem.git'
      expect(described_class.get_repo).to eq('learn-gem')
    end

    it 'supports http addresses without .git extension' do
      expect(Git).to receive(:open).and_return(repo)
      remote.url = 'https://github.com/flatiron-labs/learn-gem'
      expect(described_class.get_repo).to eq('learn-gem')
    end
  end
end

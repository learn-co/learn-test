require 'spec_helper'
RSpec.describe Ironboard::RepoParser do
  context "URLs from github" do
    let!(:remote) { OpenStruct.new(:url => nil)}
    let!(:repo) { OpenStruct.new(:remote => remote)}

    it "supports ssh addresses" do
      expect(Git).to receive(:open).and_return(repo)
      remote.url = "git@github.com:flatiron-labs/ironboard-gem.git"
      expect(described_class.get_repo).to eq("ironboard-gem")
    end

    it "supports http addresses" do
      expect(Git).to receive(:open).and_return(repo)
      remote.url = "https://github.com/flatiron-labs/ironboard-gem.git"
      expect(described_class.get_repo).to eq("ironboard-gem")
    end

    it "supports http addresses without .git extension" do
      expect(Git).to receive(:open).and_return(repo)
      remote.url = "https://github.com/flatiron-labs/ironboard-gem"
      expect(described_class.get_repo).to eq("ironboard-gem")
    end
  end
end

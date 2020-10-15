describe LearnTest::Git::Wip do
  let(:branch) { rand(0..999999).to_s }

  describe LearnTest::Git::Wip::Error do
    it 'should inherit from StandardError' do
      expect(described_class).to be < StandardError
    end
  end

  describe LearnTest::Git::Wip::NoChangesError do
    it 'should inherit from Error' do
      expect(described_class).to be < LearnTest::Git::Wip::Error
    end

    it 'should require a branch' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it 'should have the correct messaging' do
      error = described_class.new(branch)
      expect(error.message).to eq "No changes found on `#{branch}`" 
    end
  end

  describe LearnTest::Git::Wip::NoCommitsError do
    it 'should inherit from Error' do
      expect(described_class).to be < LearnTest::Git::Wip::Error
    end

    it 'should require a branch' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it 'should have the correct messaging' do
      error = described_class.new(branch)
      expect(error.message).to eq "Branch `#{branch}` doesn't have any commits. Please commit and try again." 
    end
  end
end

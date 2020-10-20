# frozen_string_literal: true

describe LearnTest::Git::Wip::Errors::NoCommitsError do
  let(:branch) { rand(0..999_999).to_s }

  it 'should inherit from Error' do
    expect(described_class).to be < LearnTest::Git::Wip::Errors::BaseError
  end

  it 'should require a branch' do
    expect { described_class.new }.to raise_error(ArgumentError)
  end

  it 'should have the correct messaging' do
    error = described_class.new(branch)
    expect(error.message).to eq "Branch `#{branch}` doesn't have any commits. Please commit and try again."
  end
end

# frozen_string_literal: true

describe LearnTest::Git::Wip::Errors::BaseError do
  it 'should inherit from StandardError' do
    expect(described_class).to be < StandardError
  end
end

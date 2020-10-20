# frozen_string_literal: true

describe LearnTest::Git do
  describe '.open' do
    context 'defaults' do
      it 'should instantiate LearnTest::Git::Base' do
        expect(LearnTest::Git::Base).to receive(:open).with('./', {})
        LearnTest::Git.open
      end
    end

    context 'with options' do
      it 'should instantiate LearnTest::Git::Base' do
        directory = './foo'
        options = { logger: false }

        expect(LearnTest::Git::Base).to receive(:open).with(directory, options)

        LearnTest::Git.open(
          directory: directory,
          options: options
        )
      end
    end
  end

  describe LearnTest::Git::Base do
    it 'should inherit from ::Git::Base' do
      expect(LearnTest::Git::Base).to be < ::Git::Base
    end

    describe '#wip' do
      let!(:repo) { described_class.open('./') }
      let!(:message) { 'FooBar' }
      let!(:wip) { double(LearnTest::Git::Wip::Base) }

      it 'should require a :message' do
        expect { repo.wip }.to raise_error(ArgumentError)
      end

      it 'should instantiate and run .process!' do
        expect(LearnTest::Git::Wip::Base)
          .to receive(:new)
          .with(base: repo, message: message)
          .and_return(wip)

        expect(wip).to receive(:process!)

        expect(repo.wip(message: message)).to eq(wip)
      end
    end
  end
end

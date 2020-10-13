# frozen_string_literal: true

describe LearnTest::Git do
  describe '#run!' do
    it 'should do something' do
      logger = Logger.new(STDOUT, level: Logger::WARN)
      repo = LearnTest::Git.open(options: { log: logger })

      res = repo.wip(message: 'Testing')
      repo.push('origin', "#{res.wip_branch}:refs/heads/fis-wip") if res
    end
  end
end

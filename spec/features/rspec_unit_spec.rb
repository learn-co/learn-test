# frozen_string_literal: true

describe 'Running a RSpec Unit Test', type: :aruba do
  before :all do
    # While it doesn't cause these tests to fail, nasty messages occur (and more)
    # when either a ~/.netrc entry or file itself doesn't exist. This aims to correct that,
    # and will only ever be called once.

    LearnTest::UsernameParser.get_username
  end

  before :each do
    copy '%/rspec-unit-spec', 'example'
    cd 'example'

    git_init
    git_add
    git_commit 'Initial Commit'
  end

  def run(flags = '')
    run_command_and_stop("#{File.join(LearnTest.bin, 'learn-test')} #{flags}")
    last_command_started.output
  end

  context 'a basic rspec unit test' do
    it 'runs the spec with 0 failures' do
      output = run('--local --test')

      expect(output).to include('3 examples, 0 failures')
      expect(output).to_not include('1 failures')
    end
  end

  context 'with the --example flag' do
    it 'runs only the appropriate tests' do
      output = run('--local --test --example multiple')

      expect(output).to include('1 example, 0 failures')
      expect(output).to_not include('2 examples')
    end

    it 'accepts multiple examples' do
      output = run(' --local --test --example multiple --example accepts')

      expect(output).to include('2 examples, 0 failures')
      expect(output).to_not include('3 examples')
      expect(output).to_not include('1 example')
    end
  end
end

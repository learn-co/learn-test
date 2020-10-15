# frozen_string_literal: true

require 'tempfile'
require 'json'

describe LearnTest::Reporter do
  let!(:client) { instance_spy(LearnTest::Client) }
  let!(:git_base) { double(LearnTest::Git::Base) }
  let!(:git_wip) { double(LearnTest::Git::Wip::Base) }
  let!(:strategy) do
    instance_spy(
      LearnTest::Strategy,
      service_endpoint: 'test_endpoint',
      results: { test: 'result' }
    )
  end

  def with_file(name, content = nil, &block)
    file = Tempfile.new(name)
    if content
      file.write("#{JSON.dump(content)}\n")
      file.flush
    end

    block.call(file)
  ensure
    file.close!
  end

  describe '#report' do
    let(:reporter) { described_class.new(strategy, client: client) }

    context 'with debug flag and failed attempt posting results' do
      it 'outputs an error message' do
        allow(client).to receive(:post_results).and_return(false)

        expect do
          reporter.debug = true
          reporter.report
        end.to output(/Learn/i).to_stdout
      end
    end

    context 'sync with Github' do
      it 'should not run LearnTest::Git::Wip, if :post_results fails' do
        expect(client).to receive(:post_results).and_return(false)
        expect(LearnTest::Git).to_not receive(:open)

        reporter.report
      end

      it 'should run LearnTest::Git::Wip' do
        branch = double(LearnTest::Git::Wip::Branch)
        branch_name = 'foo'

        expect(client).to receive(:post_results).and_return(true)
        expect(LearnTest::Git).to receive(:open).and_return(git_base)
        expect(git_base).to receive(:wip).and_return(git_wip)
        expect(git_wip).to receive(:success?).and_return(true)

        expect(branch).to receive(:to_s).and_return(branch_name)
        expect(git_wip).to receive(:wip_branch).and_return(branch)

        expect(git_base)
          .to receive(:push)
          .with('origin', "#{branch_name}:refs/heads/fis-wip", { force: true })

        reporter.report
      end

      it 'should not output an error message without debug' do
        expect(client).to receive(:post_results).and_return(true)
        expect(LearnTest::Git).to receive(:open).and_return(git_base)
        expect(git_base).to receive(:wip).and_return(git_wip)
        expect(git_wip).to receive(:success?).and_return(false)

        expect(git_base).to_not receive(:push)

        expect { reporter.report }.to_not output.to_stdout
      end

      it 'should output an error message with debug' do
        expect(client).to receive(:post_results).and_return(true)

        expect(LearnTest::Git).to receive(:open).and_return(git_base)
        expect(git_base).to receive(:wip).and_return(git_wip)
        expect(git_wip).to receive(:success?).and_return(false)

        expect(git_base).to_not receive(:push)

        expect do
          reporter.debug = true
          reporter.report
        end.to output(/There was a problem creating your WIP branch/i).to_stdout
      end
    end

    it 'posts results to the service endpoint' do
      branch = double(LearnTest::Git::Wip::Branch)
      branch_name = 'bar'

      expect(LearnTest::Git).to receive(:open).and_return(git_base)
      expect(git_base).to receive(:wip).and_return(git_wip)
      expect(git_wip).to receive(:success?).and_return(true)

      expect(branch).to receive(:to_s).and_return(branch_name)
      expect(git_wip).to receive(:wip_branch).and_return(branch)

      expect(git_base)
        .to receive(:push)
        .with('origin', "#{branch_name}:refs/heads/fis-wip", { force: true })

      reporter.report

      expect(client).to have_received(:post_results)
        .with(strategy.service_endpoint, strategy.results)
    end

    it 'does not output an error message without debug' do
      expect(client).to receive(:post_results).and_return(false)
      expect { reporter.report }.to_not output.to_stdout
    end

    it 'saves the failed attempt when the post results call fails' do
      allow(client).to receive(:post_results).and_return(false)

      with_file('test') do |tmp_file|
        reporter.output_path = tmp_file.path
        reporter.report

        report = JSON.dump(strategy.results)
        expect(File.exist?(tmp_file.path)).to be(true)
        expect(reporter.failed_reports).to eq({
          strategy.service_endpoint => [JSON.parse(report)]
        })
      end
    end

    it 'appends multiple failed attempts' do
      allow(client).to receive(:post_results).and_return(false)

      with_file('test') do |tmp_file|
        reporter.output_path = tmp_file.path

        reporter.report
        reporter.report

        report = JSON.dump(strategy.results)
        json_report = JSON.parse(report)

        expect(File.exist?(tmp_file.path)).to be(true)
        expect(reporter.failed_reports).to eq({
          strategy.service_endpoint => [json_report, json_report]
        })
      end
    end
  end

  describe '#retry_failed_reports' do
    let(:reporter) { described_class.new(strategy, client: client) }

    it 'deletes the output file when all reports are sent successfully' do
      allow(client).to receive(:post_results).and_return(true)

      reports = { hello: ['world'] }

      with_file('retry_failed_reports', reports) do |file|
        reporter.output_path = file.path
        reporter.retry_failed_reports

        expect(File.exist?(file.path)).to be(false)
      end
    end

    it 'writes the remaining reports from the output file' do
      allow(client).to receive(:post_results).and_return(true, false)

      reports = { success: ['world'], failure: ['hello'] }

      with_file('retry_failed_reports', reports) do |file|
        reporter.output_path = file.path
        reporter.retry_failed_reports

        expect(File.exist?(file.path)).to be(true)
        expect(reporter.failed_reports).to eq({ 'failure' => ['hello'] })
      end
    end
  end

  describe '#failed_reports' do
    let(:path) { 'failed_reports' }
    let(:reporter) { described_class.new(strategy, output_path: path) }

    subject { reporter.failed_reports }

    context 'with no file at location' do
      it { is_expected.to eq({}) }
    end

    context 'with no content in the file' do
      it { with_file(path) { is_expected.to eq({}) } }
    end

    context 'with returns the JSON contents of the file' do
      it {
        with_file(path, { hello: 'world' }) do |file|
          reporter.output_path = file.path
          is_expected.to eq({ 'hello' => 'world' })
        end
      }
    end
  end
end

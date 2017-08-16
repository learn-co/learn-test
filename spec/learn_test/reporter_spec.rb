require 'spec_helper'

require_relative '../../lib/learn_test/reporter'

require 'tempfile'
require 'json'

describe LearnTest::Reporter do
  let(:strategy) {
    instance_spy(
      LearnTest::Strategy,
      service_endpoint: "test_endpoint",
      results: { test: 'result' }
    )
  }
  let(:client) { instance_spy(LearnTest::Client) }

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

    context "with debug flag and failed attempt posting results" do
      it "outputs an error message" do
        allow(client).to receive(:post_results).and_return(false)
        reporter.debug = true
        io = StringIO.new

        reporter.report(out: io)

        expect(io.string).to_not be_empty
      end
    end

    it 'posts results to the service endpoint' do
      reporter.report

      expect(client).to have_received(:post_results)
        .with(strategy.service_endpoint, strategy.results)
    end

    it 'does not output an error message without debug' do
      allow(client).to receive(:post_results).and_return(false)
      io = StringIO.new

      with_file('test_debug') do |tmp_file|
        reporter.output_path = tmp_file.path

        reporter.report(out: io)

        expect(io.string).to be_empty
      end
    end

    it 'saves the failed attempt when the post results call fails' do
      allow(client).to receive(:post_results).and_return(false)

      with_file('test') do |tmp_file|
        reporter.output_path = tmp_file.path
        reporter.report

        report = JSON.dump(strategy.results)
        expect(File.exists?(tmp_file.path)).to be(true)
        expect(reporter.failed_reports).to eq({
          strategy.service_endpoint => [JSON.load(report)]
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
        json_report = JSON.load(report)
        expect(File.exists?(tmp_file.path)).to be(true)
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
      reports = {hello: ["world"]}
      with_file('retry_failed_reports', reports) do |file|
        reporter.output_path = file.path
        reporter.retry_failed_reports

        expect(File.exists?(file.path)).to be(false)
      end
    end

    it 'writes the remaining reports from the output file' do
      allow(client).to receive(:post_results).and_return(true, false)
      reports = {success: ["world"], failure: ["hello"]}
      with_file('retry_failed_reports', reports) do |file|
        reporter.output_path = file.path
        reporter.retry_failed_reports
        expect(File.exists?(file.path)).to be(true)
        expect(reporter.failed_reports).to eq({"failure" => ["hello"]})
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
        with_file(path, {hello: "world"}) do |file|
          reporter.output_path = file.path
          is_expected.to eq({"hello" => "world"})
        end
      }
    end
  end
end

describe LearnTest::Client do
  subject { described_class }

  after { Faraday.default_connection = nil }

  context '.initialize' do
    it 'should initialize Faraday' do
      dbl = double.as_null_object

      expect(Faraday).to receive(:new).with(url: subject::SERVICE_URL).and_yield(dbl)
      expect(dbl).to receive(:adapter).with(:net_http)

      subject.new
    end
  end

  context '#post_results' do
    let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
    let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }

    it 'should call the endpoint with test results and return true' do
      expect(Faraday).to receive(:new).and_return(conn)

      stubs.post('/') do |env|
        expect(env.url.path).to eq('/')
        expect(env.request_headers['Content-Type']).to eq('application/json')
        expect(env.request_body).to eq('{"foo":"bar"}')
      end

      expect(subject.new.post_results('/', {foo: 'bar'})).to be(true)

      stubs.verify_stubbed_calls
    end

    it 'should return false on failure' do
      expect(Faraday).to receive(:new).and_return(conn)

      stubs.post('/') { raise Faraday::ConnectionFailed, nil }

      expect(subject.new.post_results('/', {})).to be(false)

      stubs.verify_stubbed_calls
    end
  end
end

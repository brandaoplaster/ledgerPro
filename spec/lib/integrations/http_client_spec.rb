require 'rails_helper'

describe Integrations::HttpClient do
  let(:base_url) { 'https://api.example.com' }
  let(:api_key) { 'test_key_123' }
  let(:timeout) { 20 }
  let(:endpoint) { '/users' }
  let(:params) { { page: 1, limit: 10 } }
  let(:body) { { name: 'John', email: 'john@example.com' } }
  let(:custom_headers) { { 'X-Custom' => 'value', 'Authorization' => 'Bearer token' } }

  subject { described_class.new(base_url: base_url, api_key: api_key, timeout: timeout) }

  describe '#initialize' do
    it 'creates ErrorHandler instance' do
      client = described_class.new(base_url: base_url, api_key: api_key)
      error_handler = client.instance_variable_get(:@error_handler)
      expect(error_handler).to be_a(Integrations::ErrorHandler)
    end

    it 'uses DEFAULT_TIMEOUT when timeout not provided' do
      client = described_class.new(base_url: base_url, api_key: api_key)
      expect(client.instance_variable_get(:@timeout)).to eq(described_class::DEFAULT_TIMEOUT)
    end

    it 'stores api_key' do
      client = described_class.new(base_url: base_url, api_key: api_key)
      expect(client.instance_variable_get(:@api_key)).to eq(api_key)
    end

    it 'stores base_url without trailing slash' do
      client = described_class.new(base_url: 'https://api.example.com/', api_key: api_key)
      expect(client.instance_variable_get(:@base_url)).to eq('https://api.example.com')
    end
  end

  describe 'HTTP methods integration' do
    let(:response_body) { { result: 'ok' } }
    let(:faraday_response) { double('Response', body: response_body, status: 200) }

    before do
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
    end

    describe '#get' do
      it 'calls make_request with correct method and options' do
        expect(subject).to receive(:make_request).with(:get, endpoint, params: params, headers: custom_headers)
        subject.get(endpoint, params, custom_headers)
      end

      it 'uses empty hash for params and headers by default' do
        expect(subject).to receive(:make_request).with(:get, endpoint, params: {}, headers: {})
        subject.get(endpoint)
      end

      it 'returns response body' do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(faraday_response)
        result = subject.get(endpoint)
        expect(result).to eq(response_body)
      end
    end

    describe '#delete' do
      it 'calls make_request with correct method and options' do
        expect(subject).to receive(:make_request).with(:delete, endpoint, params: params, headers: custom_headers)
        subject.delete(endpoint, params, custom_headers)
      end

      it 'uses empty hash for params and headers by default' do
        expect(subject).to receive(:make_request).with(:delete, endpoint, params: {}, headers: {})
        subject.delete(endpoint)
      end

      it 'returns response body' do
        allow_any_instance_of(Faraday::Connection).to receive(:delete).and_return(faraday_response)
        result = subject.delete(endpoint)
        expect(result).to eq(response_body)
      end
    end

    describe '#post' do
      it 'calls make_request with correct method and options' do
        expect(subject).to receive(:make_request).with(:post, endpoint, body: body, headers: custom_headers)
        subject.post(endpoint, body, custom_headers)
      end

      it 'uses nil body and empty headers by default' do
        expect(subject).to receive(:make_request).with(:post, endpoint, body: nil, headers: {})
        subject.post(endpoint)
      end

      it 'returns response body' do
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(faraday_response)
        result = subject.post(endpoint, body)
        expect(result).to eq(response_body)
      end
    end

    describe '#put' do
      it 'calls make_request with correct method and options' do
        expect(subject).to receive(:make_request).with(:put, endpoint, body: body, headers: custom_headers)
        subject.put(endpoint, body, custom_headers)
      end

      it 'uses nil body and empty headers by default' do
        expect(subject).to receive(:make_request).with(:put, endpoint, body: nil, headers: {})
        subject.put(endpoint)
      end

      it 'returns response body' do
        allow_any_instance_of(Faraday::Connection).to receive(:put).and_return(faraday_response)
        result = subject.put(endpoint, body)
        expect(result).to eq(response_body)
      end
    end

    describe '#patch' do
      it 'calls make_request with correct method and options' do
        expect(subject).to receive(:make_request).with(:patch, endpoint, body: body, headers: custom_headers)
        subject.patch(endpoint, body, custom_headers)
      end

      it 'uses nil body and empty headers by default' do
        expect(subject).to receive(:make_request).with(:patch, endpoint, body: nil, headers: {})
        subject.patch(endpoint)
      end

      it 'returns response body' do
        allow_any_instance_of(Faraday::Connection).to receive(:patch).and_return(faraday_response)
        result = subject.patch(endpoint, body)
        expect(result).to eq(response_body)
      end
    end
  end

  describe 'error handling' do
    let(:faraday_response) { double('Response', body: { result: 'ok' }, status: 200) }

    before do
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
    end

    it 'delegates timeout errors to error_handler' do
      error = Faraday::TimeoutError.new('timeout')
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(error)

      error_handler = subject.instance_variable_get(:@error_handler)
      expect(error_handler).to receive(:handle).with(error)

      subject.get(endpoint) rescue nil
    end

    it 'logs errors with method and URL' do
      error = Faraday::ConnectionFailed.new('failed')
      allow_any_instance_of(Faraday::Connection).to receive(:post).and_raise(error)

      expect(Rails.logger).to receive(:error).with(/POST.*ConnectionFailed/i)
      subject.post(endpoint, body) rescue nil
    end

    it 'logs successful requests with status' do
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(faraday_response)

      expect(Rails.logger).to receive(:info).with(/GET.*200/)
      subject.get(endpoint)
    end
  end

  describe 'request configuration' do
    let(:faraday_request) { double('Request') }
    let(:faraday_response) { double('Response', body: { result: 'ok' }, status: 200) }

    before do
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
      allow(faraday_request).to receive(:headers).and_return(double(update: nil))
      allow(faraday_request).to receive(:params).and_return(double(update: nil))
      allow(faraday_request).to receive(:body=)

      [ :get, :post, :put, :patch, :delete ].each do |method|
        allow_any_instance_of(Faraday::Connection).to receive(method) do |&block|
          block.call(faraday_request) if block
          faraday_response
        end
      end
    end

    it 'updates headers with build_headers result' do
      expect(faraday_request.headers).to receive(:update)
        .with(hash_including('Accept' => 'application/json', 'Content-Type' => 'application/json'))

      subject.post(endpoint, body)
    end

    it 'includes Authorization header when api_key present' do
      expect(faraday_request.headers).to receive(:update)
        .with(hash_including('Authorization' => 'Bearer test_key_123'))

      subject.post(endpoint, body)
    end

    it 'updates params when provided' do
      expect(faraday_request.params).to receive(:update).with(params)

      subject.get(endpoint, params)
    end

    it 'does not update params when empty' do
      expect(faraday_request.params).not_to receive(:update)

      subject.get(endpoint, {})
    end

    it 'sets body when provided' do
      expect(faraday_request).to receive(:body=).with(body)

      subject.post(endpoint, body)
    end

    it 'does not set body when nil' do
      expect(faraday_request).not_to receive(:body=)

      subject.post(endpoint, nil)
    end

    it 'omits Content-Type for GET requests' do
      expect(faraday_request.headers).to receive(:update) do |headers|
        expect(headers).not_to have_key('Content-Type')
      end

      subject.get(endpoint)
    end

    it 'merges custom headers' do
      expect(faraday_request.headers).to receive(:update)
        .with(hash_including('X-Custom' => 'value'))

      subject.post(endpoint, body, { 'X-Custom' => 'value' })
    end
  end

  describe 'constants' do
    it 'defines DEFAULT_TIMEOUT as 10' do
      expect(described_class::DEFAULT_TIMEOUT).to eq(10)
    end

    it 'defines DEFAULT_RETRIES as 3' do
      expect(described_class::DEFAULT_RETRIES).to eq(3)
    end
  end
end

require 'rails_helper'
require 'faraday/retry'
require_relative '../../app/integrations/http_client'
require_relative '../../app/integrations/error_handler'

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
    it 'creates Faraday connection with base_url' do
      client = described_class.new(base_url: base_url, api_key: api_key, timeout: timeout)
      connection = client.send(:conn)
      expect(connection).to be_a(Faraday::Connection)
      expect(connection.url_prefix.to_s).to eq("#{base_url}/")
    end

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
  end

  describe '#build_connection (private)' do
    it 'configures JSON request middleware' do
      connection = subject.send(:conn)
      handlers = connection.builder.handlers
      expect(handlers).to include(Faraday::Request::Json)
    end

    it 'configures JSON response middleware' do
      connection = subject.send(:conn)
      handlers = connection.builder.handlers
      expect(handlers).to include(Faraday::Response::Json)
    end

    it 'sets timeout option' do
      connection = subject.send(:conn)
      expect(connection.options.timeout).to eq(timeout)
    end

    it 'uses DEFAULT_TIMEOUT when timeout not specified' do
      client = described_class.new(base_url: base_url, api_key: api_key)
      connection = client.send(:conn)
      expect(connection.options.timeout).to eq(described_class::DEFAULT_TIMEOUT)
    end
  end

  describe '#build_request (private)' do
    let(:request_mock) do
      double('Request').tap do |mock|
        @body_value = nil

        allow(mock).to receive(:headers).and_return({})
        allow(mock).to receive(:params).and_return({})

        allow(mock).to receive(:body=) { |val| @body_value = val }

        allow(mock).to receive(:body) { @body_value }

        allow(mock.headers).to receive(:update)
        allow(mock.params).to receive(:update)
      end
    end

    before do
      allow(request_mock.headers).to receive(:update)
      allow(request_mock.params).to receive(:update)
    end

    it 'adds default headers to request' do
      expect(request_mock.headers).to receive(:update).with({
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      })

      subject.send(:build_request, request_mock, {})
    end

    it 'adds custom headers when provided' do
      expect(request_mock.headers).to receive(:update).with(custom_headers)

      subject.send(:build_request, request_mock, { headers: custom_headers })
    end

    it 'sets body when provided' do
      subject.send(:build_request, request_mock, { body: body })
      expect(request_mock.body).to eq(body)
    end

    it 'sets query params when provided' do
      expect(request_mock.params).to receive(:update).with(params)

      subject.send(:build_request, request_mock, { query: params })
    end

    it 'does not set body when not provided' do
      subject.send(:build_request, request_mock, {})
      expect(request_mock.body).to be_nil
    end

    it 'handles all options together' do
      expect(request_mock.headers).to receive(:update).twice
      expect(request_mock.params).to receive(:update).with(params)

      subject.send(:build_request, request_mock, {
        headers: custom_headers,
        body: body,
        query: params
      })

      expect(request_mock.body).to eq(body)
    end
  end

  describe '#default_headers (private)' do
    it 'returns Content-Type and Accept headers' do
      headers = subject.send(:default_headers)
      expect(headers).to eq({
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      })
    end

    it 'returns hash with string keys' do
      headers = subject.send(:default_headers)
      expect(headers.keys).to all(be_a(String))
    end
  end

  describe '#execute (private)' do
    let(:response_body) { { success: true, data: [] } }
    let(:faraday_response) { double('Response', body: response_body) }
    let(:connection) { subject.send(:conn) }

    before do
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
    end

    it 'logs successful request' do
      allow(connection).to receive(:get).and_return(faraday_response)

      expect(Rails.logger).to receive(:info).with("get - #{endpoint}")

      subject.send(:execute, :get, endpoint, {})
    end

    it 'calls build_request with request object and options' do
      allow(connection).to receive(:post).and_yield(double('Request').as_null_object).and_return(faraday_response)

      options = { body: body, headers: custom_headers }
      expect(subject).to receive(:build_request).with(anything, options)

      subject.send(:execute, :post, endpoint, options)
    end

    it 'returns response body on success' do
      allow(connection).to receive(:get).and_return(faraday_response)

      result = subject.send(:execute, :get, endpoint, {})
      expect(result).to eq(response_body)
    end

    context 'when error occurs' do
      let(:error) { Faraday::TimeoutError.new('timeout') }
      let(:error_handler) { subject.instance_variable_get(:@error_handler) }

      it 'logs error details' do
        allow(connection).to receive(:get).and_raise(error)

        expect(Rails.logger).to receive(:error).with(
          "GET #{endpoint} - Failed: Faraday::TimeoutError - timeout"
        )

        subject.send(:execute, :get, endpoint, {}) rescue nil
      end

      it 'delegates error to error_handler' do
        allow(connection).to receive(:get).and_raise(error)

        expect(error_handler).to receive(:handle).with(error)

        subject.send(:execute, :get, endpoint, {}) rescue nil
      end

      it 're-raises error from error_handler' do
        allow(connection).to receive(:get).and_raise(error)
        allow(error_handler).to receive(:handle).and_raise(Integrations::TimeoutError, 'Request timeout')

        expect {
          subject.send(:execute, :get, endpoint, {})
        }.to raise_error(Integrations::TimeoutError, 'Request timeout')
      end
    end
  end

  describe 'HTTP methods integration' do
    let(:response_body) { { result: 'ok' } }
    let(:faraday_response) { double('Response', body: response_body) }
    let(:connection) { subject.send(:conn) }

    before do
      allow(Rails.logger).to receive(:info)
    end

    describe '#get' do
      it 'calls execute with correct method and options' do
        expect(subject).to receive(:execute).with(:get, endpoint, { query: params, headers: custom_headers })
        subject.get(endpoint, params, custom_headers)
      end

      it 'uses empty hash for params and headers by default' do
        expect(subject).to receive(:execute).with(:get, endpoint, { query: {}, headers: {} })
        subject.get(endpoint)
      end
    end

    describe '#post' do
      it 'calls execute with correct method and options' do
        expect(subject).to receive(:execute).with(:post, endpoint, { body: body, headers: custom_headers })
        subject.post(endpoint, body, custom_headers)
      end

      it 'uses nil body and empty headers by default' do
        expect(subject).to receive(:execute).with(:post, endpoint, { body: nil, headers: {} })
        subject.post(endpoint)
      end
    end

    describe '#put' do
      it 'calls execute with correct method and options' do
        expect(subject).to receive(:execute).with(:put, endpoint, { body: body, headers: custom_headers })
        subject.put(endpoint, body, custom_headers)
      end

      it 'uses nil body and empty headers by default' do
        expect(subject).to receive(:execute).with(:put, endpoint, { body: nil, headers: {} })
        subject.put(endpoint)
      end
    end

    describe '#patch' do
      it 'calls execute with correct method and options' do
        expect(subject).to receive(:execute).with(:patch, endpoint, { body: body, headers: custom_headers })
        subject.patch(endpoint, body, custom_headers)
      end

      it 'uses nil body and empty headers by default' do
        expect(subject).to receive(:execute).with(:patch, endpoint, { body: nil, headers: {} })
        subject.patch(endpoint)
      end
    end

    describe '#delete' do
      it 'calls execute with correct method and options' do
        expect(subject).to receive(:execute).with(:delete, endpoint, { query: params, headers: custom_headers })
        subject.delete(endpoint, params, custom_headers)
      end

      it 'uses empty hash for params and headers by default' do
        expect(subject).to receive(:execute).with(:delete, endpoint, { query: {}, headers: {} })
        subject.delete(endpoint)
      end
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

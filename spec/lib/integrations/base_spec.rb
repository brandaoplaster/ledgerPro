require 'rails_helper'

describe Integrations::Base do
  let(:base_url) { 'https://api.example.com' }
  let(:api_key) { 'test_key' }
  let(:timeout) { 30 }
  let(:client_mock) { double('HttpClient') }
  let(:endpoint) { '/test' }
  let(:params) { { q: 'search' } }
  let(:body) { { name: 'test' } }
  let(:custom_headers) { { 'X-Custom' => 'header' } }
  let(:response) { { success: true } }

  subject { described_class.new(base_url: base_url, api_key: api_key, timeout: timeout) }

  before do
    allow(Integrations::HttpClient).to receive(:new).and_return(client_mock)
  end

  describe '#initialize' do
    it 'creates HttpClient with correct params' do
      expect(Integrations::HttpClient).to receive(:new).with(
        base_url: base_url,
        api_key: api_key,
        timeout: timeout
      ).and_return(client_mock)

      described_class.new(base_url: base_url, api_key: api_key, timeout: timeout)
    end

    it 'makes client accessible via attr_reader' do
      expect(subject.send(:client)).to eq(client_mock)
    end
  end

  describe '#get' do
    it 'delegates get to client' do
      expect(client_mock).to receive(:get).with(endpoint, params, custom_headers).and_return(response)

      result = subject.send(:get, endpoint, params, custom_headers)
      expect(result).to eq(response)
    end

    it 'delegates get with default params' do
      expect(client_mock).to receive(:get).with(endpoint, {}, {}).and_return(response)
      subject.send(:get, endpoint)
    end

    it 'returns client response' do
      allow(client_mock).to receive(:get).and_return(response)
      expect(subject.send(:get, endpoint)).to eq(response)
    end
  end

  describe '#post' do
    it 'delegates post to client with body' do
      expect(client_mock).to receive(:post).with(endpoint, body, custom_headers).and_return(response)
      result = subject.send(:post, endpoint, body, custom_headers)
      expect(result).to eq(response)
    end

    it 'delegates post with default params' do
      expect(client_mock).to receive(:post).with(endpoint, nil, {}).and_return(response)
      subject.send(:post, endpoint)
    end

    it 'returns client response' do
      allow(client_mock).to receive(:post).and_return(response)
      expect(subject.send(:post, endpoint, body)).to eq(response)
    end
  end

  describe '#put' do
    it 'delegates put to client with body' do
      expect(client_mock).to receive(:put).with(endpoint, body).and_return(response)
      result = subject.send(:put, endpoint, body)
      expect(result).to eq(response)
    end

    it 'delegates put with default body' do
      expect(client_mock).to receive(:put).with(endpoint, nil).and_return(response)
      subject.send(:put, endpoint)
    end

    it 'returns client response' do
      allow(client_mock).to receive(:put).and_return(response)
      expect(subject.send(:put, endpoint)).to eq(response)
    end
  end

  describe '#patch' do
    it 'delegates patch to client with body' do
      expect(client_mock).to receive(:patch).with(endpoint, body).and_return(response)
      result = subject.send(:patch, endpoint, body)
      expect(result).to eq(response)
    end

    it 'delegates patch with default body' do
      expect(client_mock).to receive(:patch).with(endpoint, nil).and_return(response)
      subject.send(:patch, endpoint)
    end

    it 'returns client response' do
      allow(client_mock).to receive(:patch).and_return(response)
      expect(subject.send(:patch, endpoint)).to eq(response)
    end
  end

  describe '#delete' do
    it 'delegates delete to client with params' do
      expect(client_mock).to receive(:delete).with(endpoint, params).and_return(response)
      result = subject.send(:delete, endpoint, params)
      expect(result).to eq(response)
    end

    it 'delegates delete with default params' do
      expect(client_mock).to receive(:delete).with(endpoint, {}).and_return(response)
      subject.send(:delete, endpoint)
    end

    it 'returns client response' do
      allow(client_mock).to receive(:delete).and_return(response)
      expect(subject.send(:delete, endpoint)).to eq(response)
    end
  end
end

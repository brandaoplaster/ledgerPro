require 'rails_helper'

describe Integrations::ErrorHandler do
  let(:handler) { described_class.new }

  describe '#initialize' do
    it 'initializes strategies as Hash' do
      expect(handler.instance_variable_get(:@strategies)).to be_a(Hash)
    end

    it 'contains all expected error mappings' do
      strategies = handler.instance_variable_get(:@strategies)
      expected_keys = [
        Faraday::TimeoutError,
        Faraday::ConnectionFailed,
        Faraday::TooManyRequestsError,
        Faraday::UnauthorizedError,
        Faraday::ForbiddenError,
        Faraday::ResourceNotFound,
        Faraday::ServerError,
        Faraday::ClientError,
        :default
      ]
      expect(strategies.keys).to match_array(expected_keys)
    end
  end

  describe '#handle' do
    context 'with TimeoutError' do
      it 'raises TimeoutError with message' do
        error = Faraday::TimeoutError.new('timeout message')
        expect { handler.handle(error) }.to raise_error(Integrations::TimeoutError, 'Request timeout')
      end
    end

    context 'with ConnectionFailed' do
      it 'raises ConnectionError with message' do
        error = Faraday::ConnectionFailed.new('connection failed')
        expect { handler.handle(error) }.to raise_error(Integrations::ConnectionError, /Connection failed/)
      end
    end

    context 'with TooManyRequestsError' do
      it 'raises RateLimitError with message' do
        error = Faraday::TooManyRequestsError.new('rate limit')
        expect { handler.handle(error) }.to raise_error(Integrations::RateLimitError, 'Rate limit exceeded')
      end
    end

    context 'with UnauthorizedError' do
      it 'raises AuthenticationError with message' do
        error = Faraday::UnauthorizedError.new('unauthorized')
        expect { handler.handle(error) }.to raise_error(Integrations::AuthenticationError, 'Invalid credentials')
      end
    end

    context 'with ForbiddenError' do
      it 'raises AuthorizationError with message' do
        error = Faraday::ForbiddenError.new('forbidden')
        expect { handler.handle(error) }.to raise_error(Integrations::AuthorizationError, 'Access denied')
      end
    end

    context 'with ResourceNotFound' do
        it 'raises NotFoundError with message' do
          error = Faraday::ResourceNotFound.new('not found')
          expect { handler.handle(error) }.to raise_error(Integrations::NotFoundError, 'Resource not found')
        end
      end

    context 'with ServerError' do
      it 'raises ServerError with message' do
        error = Faraday::ServerError.new('server error')
        expect { handler.handle(error) }.to raise_error(Integrations::ServerError, /Server error/)
      end
    end

    context 'with ClientError' do
      it 'raises ClientError with message' do
        error = Faraday::ClientError.new('client error')
        expect { handler.handle(error) }.to raise_error(Integrations::ClientError, /Client error/)
      end
    end

    context 'with unmapped error' do
      it 'raises RequestError with original message' do
        error = StandardError.new('unknown error')
        expect { handler.handle(error) }.to raise_error(Integrations::RequestError, /HTTP request failed: unknown error/)
      end
    end
  end
end

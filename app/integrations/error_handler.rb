module Integrations
  class ErrorHandler
    def initialize
      @strategies = build_strategies
    end

    def handle(error)
      strategy = @strategies[error.class] || @strategies[:default]
      strategy.call(error)
    end

    private

    def build_strategies
      {
        Faraday::TimeoutError => ->(e) { raise TimeoutError, "Request timeout" },
        Faraday::ConnectionFailed => ->(e) { raise ConnectionError, "Connection failed: #{e.message}" },
        Faraday::TooManyRequestsError => ->(e) { raise RateLimitError, "Rate limit exceeded" },
        Faraday::UnauthorizedError => ->(e) { raise AuthenticationError, "Invalid credentials" },
        Faraday::ForbiddenError => ->(e) { raise AuthorizationError, "Access denied" },
        Faraday::ResourceNotFound => ->(e) { raise NotFoundError, "Resource not found" },
        Faraday::ServerError => ->(e) { raise ServerError, "Server error: #{e.message}" },
        Faraday::ClientError => ->(e) { raise ClientError, "Client error: #{e.message}" },
        :default => ->(e) { raise RequestError, "HTTP request failed: #{e.message}" }
      }
    end
  end

  class TimeoutError < StandardError; end
  class ConnectionError < StandardError; end
  class RateLimitError < StandardError; end
  class AuthenticationError < StandardError; end
  class AuthorizationError < StandardError; end
  class NotFoundError < StandardError; end
  class ServerError < StandardError; end
  class ClientError < StandardError; end
  class RequestError < StandardError; end
end

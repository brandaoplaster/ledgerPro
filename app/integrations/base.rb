module Integrations
  class Base
    def initialize(base_url:, api_key: nil, timeout: nil)
      @client = HttpClient.new(base_url: base_url, api_key: api_key, timeout: timeout)
    end

    private

    attr_reader :client

    def get(endpoint, params = {}, custom_headers = {})
      client.get(endpoint, params, custom_headers)
    end

    def post(endpoint, body = nil, custom_headers = {})
      client.post(endpoint, body, custom_headers)
    end

    def put(endpoint, body = nil)
      client.put(endpoint, body)
    end

    def patch(endpoint, body = nil)
      client.patch(endpoint, body)
    end

    def delete(endpoint, params = {})
      client.delete(endpoint, params)
    end
  end
end

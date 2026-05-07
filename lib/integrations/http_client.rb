module Integrations
  class HttpClient
    DEFAULT_TIMEOUT = 10
    DEFAULT_RETRIES = 3

    def initialize(base_url:, api_key: nil, timeout: DEFAULT_TIMEOUT)
      @base_url = base_url.chomp("/")
      @api_key = api_key
      @timeout = timeout
      @error_handler = ErrorHandler.new
    end

    def get(endpoint, params = {}, headers = {})
      make_request(:get, endpoint, params: params, headers: headers)
    end

    def post(endpoint, body = nil, headers = {})
      make_request(:post, endpoint, body: body, headers: headers)
    end

    def put(endpoint, body = nil, headers = {})
      make_request(:put, endpoint, body: body, headers: headers)
    end

    def patch(endpoint, body = nil, headers = {})
      make_request(:patch, endpoint, body: body, headers: headers)
    end

    def delete(endpoint, params = {}, headers = {})
      make_request(:delete, endpoint, params: params, headers: headers)
    end

    private

    def connection
      @connection ||= Faraday.new do |f|
        f.request :json
        f.response :json
        f.request :retry, max: DEFAULT_RETRIES, interval: 0.1, max_interval: 2, backoff_factor: 2
        f.options.timeout = @timeout
        f.adapter Faraday.default_adapter
      end
    end

    def make_request(method, endpoint, params: {}, body: nil, headers: {})
      url = build_url(endpoint)
      response = connection.public_send(method, url) do |req|
        req.headers.update(build_headers(headers, method))
        req.params.update(params) if params.any?
        req.body = body if body
      end

      Rails.logger.info("#{method.upcase} #{url} - #{response.status}")
      response.body
    rescue => e
      Rails.logger.error("#{method.upcase} #{url} - #{e.class.name}: #{e.message}")
      @error_handler.handle(e)
    end

    def build_url(endpoint)
      endpoint = "/#{endpoint}" unless endpoint.start_with?("/")
      "#{@base_url}#{endpoint}"
    end

    def build_headers(custom_headers = {}, method = :get)
      {
        "Accept" => "application/json",
        "Content-Type" => ("application/json" unless [ :get, :delete ].include?(method)),
        "Authorization" => ("Bearer #{@api_key}" if @api_key)
      }.compact.merge(custom_headers)
    end
  end
end

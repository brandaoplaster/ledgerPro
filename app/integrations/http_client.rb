module Integrations
  class HttpClient
    DEFAULT_TIMEOUT = 10
    DEFAULT_RETRIES = 3

    def initialize(base_url: nil, api_key: nil, timeout: DEFAULT_TIMEOUT)
      @base_url = base_url
      @api_key = api_key
      @timeout = timeout
      @conn = build_connection
      @error_handler = ErrorHandler.new
    end

    def get(endpoint, params = {}, headers = {})
      execute(:get, endpoint, query: params, headers: headers)
    end

    def post(endpoint, body = nil, headers = {})
      execute(:post, endpoint, body: body, headers: headers)
    end

    def put(endpoint, body = nil, headers = {})
      execute(:put, endpoint, body: body, headers: headers)
    end

    def patch(endpoint, body = nil, headers = {})
      execute(:patch, endpoint, body: body, headers: headers)
    end

    def delete(endpoint, params = {}, headers = {})
      execute(:delete, endpoint, query: params, headers: headers)
    end

    private

    attr_reader :api_key, :conn

    def build_connection
      Faraday.new(url: @base_url) do |f|
        f.request :json
        f.response :json
        f.request :retry, max: DEFAULT_RETRIES, interval: 0.1, max_interval: 2, backoff_factor: 2
        f.options.timeout = @timeout
      end
    end

    def execute(method, endpoint, options = {})
      response = conn.public_send(method, endpoint) do |req|
        build_request(req, options)
      end

      Rails.logger.info("#{method} - #{endpoint}")

      response.body
    rescue => e
      Rails.logger.error("#{method.upcase} #{endpoint} - Failed: #{e.class.name} - #{e.message}")

      @error_handler.handle(e)
    end

    def build_request(req, options)
      req.headers.update(default_headers)
      req.headers.update(options[:headers]) if options[:headers]
      req.body = options[:body] if options[:body]
      req.params.update(options[:query]) if options[:query]
    end

    def default_headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }
    end
  end
end

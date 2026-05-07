module Integrations
  class Cripto < Base
    BASE_URL = "https://api.coingecko.com/api/v3"

    def initialize
      super(base_url: BASE_URL, api_key: nil, timeout: nil)
    end

    def fetch_markets(currency: "usd")
      get("/coins/markets", { vs_currency: currency })
    end
  end
end

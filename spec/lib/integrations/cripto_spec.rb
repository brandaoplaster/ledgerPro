require "rails_helper"

describe Integrations::Cripto do
  let(:http_client) { instance_double(Integrations::HttpClient) }

  before do
    allow(Integrations::HttpClient).to receive(:new).and_return(http_client)
  end

  describe "#fetch_markets" do
    let(:markets_data) do
      [
        { "id" => "bitcoin", "symbol" => "btc", "current_price" => 50000 },
        { "id" => "ethereum", "symbol" => "eth", "current_price" => 3000 }
      ]
    end

    it "fetches markets with default currency" do
      expect(http_client).to receive(:get)
        .with("/coins/markets", { vs_currency: "usd" }, {})
        .and_return(markets_data)

      result = subject.fetch_markets
      expect(result).to eq(markets_data)
    end

    it "fetches markets with custom currency" do
      expect(http_client).to receive(:get)
        .with("/coins/markets", { vs_currency: "brl" }, {})
        .and_return(markets_data)

      result = subject.fetch_markets(currency: "brl")
      expect(result).to eq(markets_data)
    end
  end
end

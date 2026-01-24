class DashboardController < ApplicationController
  def index
    @wallets = current_user.wallets.includes(:holdings, :transactions, :strategy)
    
    @total_wallets = @wallets.count
    @active_wallets = @wallets.active.count
    @inactive_wallets = @wallets.inactive.count
    
    @wallet_summaries = @wallets.map do |wallet|
      {
        wallet: wallet,
        total_invested: calculate_total_invested(wallet),
        current_value: calculate_current_value(wallet),
        holdings_count: wallet.holdings.count,
        transactions_count: wallet.transactions.count,
        has_strategy: wallet.strategy.present?
      }
    end
    
    @total_invested = @wallet_summaries.sum { |ws| ws[:total_invested] }
    @total_current_value = @wallet_summaries.sum { |ws| ws[:current_value] }
    @total_profit_loss = @total_current_value - @total_invested
    @total_profit_loss_percentage = @total_invested.zero? ? 0 : ((@total_profit_loss / @total_invested) * 100)
    
    @recent_transactions = current_user.wallets
                                       .joins(:transactions)
                                       .includes(transactions: :instrument)
                                       .merge(Transaction.order(occurred_at: :desc))
                                       .limit(10)
                                       .flat_map(&:transactions)
                                       .first(10)
    
    
    @wallet_distribution = @wallet_summaries.map do |summary|
      [summary[:wallet].name, summary[:current_value].to_f]
    end.to_h
    
    transactions_last_6_months = current_user.wallets
                                             .joins(:transactions)
                                             .where("transactions.occurred_at >= ?", 6.months.ago)
                                             .pluck("transactions.occurred_at")
    
    @transactions_by_month = transactions_last_6_months
                              .compact
                              .group_by { |date| date.beginning_of_month.strftime("%b %Y") }
                              .transform_values(&:count)
                              .sort_by { |month, _| Date.parse("01 #{month}") }
                              .to_h
    
    @buy_vs_sell = {
      "Buys" => current_user.wallets.joins(:transactions).merge(Transaction.buy).count,
      "Sells" => current_user.wallets.joins(:transactions).merge(Transaction.sell).count
    }
    
    holdings_with_instruments = current_user.wallets
                                            .joins(holdings: :instrument)
                                            .select("instruments.ticker, holdings.average_price, holdings.quantity")
    
    @top_instruments = holdings_with_instruments
                        .group_by(&:ticker)
                        .map { |ticker, holdings| 
                          total = holdings.sum { |h| (h.average_price || 0) * (h.quantity || 0) }
                          [ticker, total.to_f]
                        }
                        .sort_by { |_, value| -value }
                        .first(5)
                        .to_h
    
    @wallet_comparison_data = @wallet_summaries.map do |summary|
      [
        summary[:wallet].name,
        {
          "Invested" => summary[:total_invested].to_f,
          "Current" => summary[:current_value].to_f
        }
      ]
    end.to_h
  end
  
  private
  
  def calculate_total_invested(wallet)
    wallet.transactions.buy.sum('price * quantity')
  end
  
  def calculate_current_value(wallet)
    wallet.holdings.sum('average_price * quantity')
  end
end
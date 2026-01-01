class TransactionService
  def initialize(wallet, transaction_params)
    @wallet = wallet
    @transaction_params =  transaction_params
  end

  def execute
    ActiveRecord::Base.transaction do
      @transaction = @wallet.transactions.create!(@transaction_params)
      update_holding
      @transaction
    end
  end

  private

  def update_holding
    holding = @wallet.holdings.lock.find_or_initialize_by(instrument_id: @transaction.instrument_id)

    if @transaction.buy?
      handle_buy(holding)
    else
      handle_sell(holding)
    end

    if holding.quantity.zero?
      holding.destroy!
    else
      holding.save!
    end
  end

  def handle_buy(holding)
    new_quantity = holding.quantity.to_f + @transaction.quantity
    new_total_cost = (holding.quantity.to_f * holding.average_price.to_f) + (@transaction.quantity * @transaction.price)
    holding.quantity = new_quantity
    holding.average_price = new_total_cost / new_quantity
  end

  def handle_sell(holding)
    raise ActiveRecord::RecordInvalid.new(holding) if holding.quantity < @transaction.quantity
    holding.quantity -= @transaction.quantity
  end
end

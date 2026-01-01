class TransactionsController < ApplicationController
  before_action :set_wallet

  def index
    @transactions = Transaction.all
  end

  def show;end

  def new
    @transaction = @wallet.transactions.build
    @instruments = Instrument.all
  end

  def create
    @transaction = @wallet.transactions.build(transaction_params)

    if @transaction.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to transactions_path, notice: "Transaction created successfully!" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_wallet
    @wallet = current_user.wallets.find(params[:wallet_id])
  end

  def transaction_params
    params.require(:transaction).permit(:instrument_id, :kind, :quantity, :price)
  end
end

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
    @transaction = TransactionService.new(@wallet, transaction_params).execute

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @wallet, notice: "Transaction created successfully!"  }
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("transaction_form", partial: "form", locals: { transaction: e.record }) }
      format.html { render :new, status: :unprocessable_entity }
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

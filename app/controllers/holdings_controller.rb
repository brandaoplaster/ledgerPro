
class HoldingsController < ApplicationController
  before_action :set_wallet
  before_action :set_holding, only: [ :edit, :update, :destroy ]

  def index
    @holdings = @wallet.holdings
  end

  def new
    @holding = @wallet.holdings.build
    @instruments = Instrument.all
  end

  def create
    @holding = @wallet.holdings.build(holding_params)

    if @holding.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to instruments_path, notice: "Holding created successfully!" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if @holding.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to instruments_path, notice: "Holding deleted successfully!" }
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_wallet
    @wallet = current_user.wallets.find(params[:wallet_id])
  end

  def set_holding
    @holding = @wallet.holdings.find(params[:id])
  end

  def holding_params
    params.require(:holding).permit(:instrument_id, :quantity, :average_price)
  end
end

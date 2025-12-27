class WalletsController < ApplicationController
  before_action :set_wallet, only: [ :show, :edit, :update, :destroy ]

  def index
    @wallets = current_user.wallets
  end

  def show;end

  def new
    @wallet = current_user.wallets.build
  end

  def create
    @wallet = current_user.wallets.build(wallet_params)

    if @wallet.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to wallets_path, notice:  "Wallet created successfully!" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit;end

  def update
    if @wallet.update(wallet_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to wallets_path, notice:  "Wallet updated successfully!" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @wallet.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to wallets_path, notice: "Wallet deleted successfully!" }
    end
  end

  private

  def set_wallet
    @wallet = current_user.wallets.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to wallets_path, alert: "Wallet not found!"
  end

  def wallet_params
    params.require(:wallet).permit(:name, :status)
  end
end

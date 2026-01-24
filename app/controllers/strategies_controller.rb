class StrategiesController < ApplicationController
  before_action :set_strategy, only: [ :show, :edit, :update, :destroy ]

  def index
    @strategies = Strategy.all
  end

  def show;end

  def new
    @strategy = Strategy.new
    @wallets = current_user.wallets
  end

  def create
    @strategy = Strategy.new(strategy_params)

    if @strategy.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to strategies_path, notice:  "Strategy created successfully!" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit;end

  def update
    if @strategy.update(strategy_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to strategies_path, notice:  "Strategy updated successfully!" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @strategy.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to strategies_path, notice: "Strategy deleted successfully!" }
    end
  end

  private

  def strategy_params
    params.require(:strategy).permit(:title, :wallet_id)
  end

  def set_strategy
    @strategy = Strategy.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to strategies_path, alert: "Strategy not found!"
  end
end

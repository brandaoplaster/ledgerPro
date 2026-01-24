class StrategyRulesController < ApplicationController
  before_action :set_strategy_rule, only: [ :show, :edit, :update, :destroy ]
  before_action :set_strategies, only: [ :new, :create, :edit, :update ]

  def index
    @strategy_rules = StrategyRule.all
  end

  def show; end

  def new
    @strategy_rule = StrategyRule.new
  end

  def create
    @strategy_rule = StrategyRule.new(strategy_rules_params)

    if @strategy_rule.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to strategy_rules_path, notice: "Strategy rule created successfully!" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @strategy_rule.update(strategy_rules_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to strategy_rules_path, notice: "Strategy rules updated successfully!" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @strategy_rule.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to strategy_rules_path, notice: "Strategy rule deleted successfully!" }
    end
  end

  private

  def strategy_rules_params
    params.require(:strategy_rule).permit(:strategy_id, :asset_kind, :min_percentage, :max_percentage, :rule_type)
  end

  def set_strategy_rule
    @strategy_rule = StrategyRule.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to strategy_rules_path, alert: "Strategy rule not found!"
  end

  def set_strategies
    @strategies = Strategy.all
  end
end

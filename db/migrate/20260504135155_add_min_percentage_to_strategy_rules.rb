class AddMinPercentageToStrategyRules < ActiveRecord::Migration[8.1]
  def up
    add_column :strategy_rules, :min_percentage, :decimal, precision: 5, scale: 2, default: 0.0
  end

  def down
    remove_column :strategy_rules, :min_percentage
  end
end

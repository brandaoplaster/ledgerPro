class CreateStrategyRules < ActiveRecord::Migration[8.1]
  def change
    create_table :strategy_rules do |t|
      t.references :strategy, null: false, foreign_key: true
      t.string :asset_kind
      t.decimal :max_percentage, precision: 5, scale: 2

      t.timestamps
    end
  end
end

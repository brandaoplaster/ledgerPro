class CreateInstrumentMetrics < ActiveRecord::Migration[8.1]
  def change
    create_table :instrument_metrics do |t|
      t.references :instrument, null: false, foreign_key: true
      t.decimal :price, precision: 15, scale: 4, null: false
      t.decimal :dy, precision: 5, scale: 2
      t.decimal :p_vp, precision: 5, scale: 2
      t.decimal :daily_liquidity, precision: 15, scale: 2
      t.decimal :market_cap, precision: 20, scale: 2
      t.datetime :recorded_at, null: false

      t.timestamps
    end

    add_index :instrument_metrics, [ :instrument_id, :recorded_at ]
  end
end

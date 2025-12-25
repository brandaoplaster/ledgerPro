class CreateHoldings < ActiveRecord::Migration[8.1]
  def change
    create_table :holdings do |t|
      t.references :wallet, null: false, foreign_key: true
      t.references :asset, null: false, foreign_key: true
      t.decimal :quantity, precision: 20, scale: 8
      t.decimal :average_price, precision: 15, scale: 2

      t.timestamps
    end

    add_index :holdings, [:wallet_id, :asset_id], unique: true
  end
end

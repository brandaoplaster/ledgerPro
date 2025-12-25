class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :wallet, null: false, foreign_key: true
      t.references :asset, null: false, foreign_key: true
      t.integer :kind
      t.decimal :quantity, precision: 15, scale: 2
      t.decimal :price, precision: 15, scale: 2
      t.datetime :occurred_at

      t.timestamps
    end

    add_index :transactions, :occurred_at
    add_index :transactions, [:wallet_id, :occurred_at]
  end
end

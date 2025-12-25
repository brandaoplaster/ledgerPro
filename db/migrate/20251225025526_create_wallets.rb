class CreateWallets < ActiveRecord::Migration[8.1]
  def change
    create_table :wallets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.integer :status, default: 1, null: false

      t.timestamps
    end
  end
end

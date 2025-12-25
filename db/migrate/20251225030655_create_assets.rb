class CreateAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :assets do |t|
      t.string :ticker
      t.string :name
      t.string :kind

      t.timestamps
    end

    add_index :assets, :ticker, unique: true
  end
end

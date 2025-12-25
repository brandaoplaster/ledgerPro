class CreateStrategies < ActiveRecord::Migration[8.1]
  def change
    create_table :strategies do |t|
      t.references :wallet, null: false, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end

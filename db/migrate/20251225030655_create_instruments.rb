class CreateInstruments < ActiveRecord::Migration[8.1]
  def change
    create_table :instruments do |t|
      t.string :ticker
      t.string :name
      t.string :kind

      t.timestamps
    end

    add_index :instruments, :ticker, unique: true
  end
end

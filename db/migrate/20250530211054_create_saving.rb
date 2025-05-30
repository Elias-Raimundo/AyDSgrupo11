class CreateSaving < ActiveRecord::Migration[8.0]
  def change
    create_table :savings do |t|
      t.decimal :monto, precision: 15, scale: 2, null: false
      t.string :motivo, null: false
      t.references :account, null: false, foreign_key: true

      t.timestamps
  end
end

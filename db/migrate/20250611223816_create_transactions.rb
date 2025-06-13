class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :source_account, null: false, foreign_key: { to_table: :accounts }
      t.references :target_account, null: false, foreign_key: { to_table: :accounts }
      t.decimal :amount, precision: 12, scale: 2, null: false

      t.timestamps
    end
  end
end

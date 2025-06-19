class CreateSavingTransactions < ActiveRecord::Migration[8.0]
    def change
      create_table :saving_transactions do |t|
        t.references :account, null: false, foreign_key: true
        t.string :name, null: false
        t.decimal :amount, precision: 10, scale: 2, null: false
        t.string :transaction_type, null: false
        t.timestamps
      end
    end
end
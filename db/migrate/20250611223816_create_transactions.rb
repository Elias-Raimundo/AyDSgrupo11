class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
	create_table :transactions do |t|
     	 t.references :account, foreign_key: true
     	 t.decimal :amount, precision: 12, scale: 2
     	 t.string :transaction_type  # "credit" or "debit"

     	 t.timestamps
    end
  end
end

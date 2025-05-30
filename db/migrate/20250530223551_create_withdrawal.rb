class CreateWithdrawal < ActiveRecord::Migration[8.0]
  def change
     create_table :withdrawals do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :reason, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end

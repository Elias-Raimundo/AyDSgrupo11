class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.references :user, foreign_key: true
      t.decimal :balance, precision: 12, scale: 2, default: 0.0

      t.timestamps
    end
  end
end


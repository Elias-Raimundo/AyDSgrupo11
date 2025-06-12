class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.references :user, foreign_key: true
      t.integer :balance
      t.string :cvu, null: false
      t.string :account_alias, null: false
      t.timestamps
    end

    add_index :accounts, :cvu, unique: true
    add_index :accounts, :account_alias, unique: true
  end
end


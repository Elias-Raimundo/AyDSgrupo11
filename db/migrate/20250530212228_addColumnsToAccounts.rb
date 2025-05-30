class AddColumnsToAccounts < ActiveRecord::Migration[8.0]
  def change
      add_column :accounts, :cvu, :string, null: false
      add_column :accounts, :alias, :string, null: false

      add_index :accounts, :cvu, unique: true
  end
end

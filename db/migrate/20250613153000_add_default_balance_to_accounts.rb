class AddDefaultBalanceToAccounts < ActiveRecord::Migration[8.0]
  class Account < ActiveRecord::Base; end

  def change
    change_column_default :accounts, :balance, 0
    change_column_null :accounts, :balance, false, 0

    reversible do |dir|
      dir.up do
        Account.where(balance: nil).update_all(balance: 0)
      end
    end
  end
end

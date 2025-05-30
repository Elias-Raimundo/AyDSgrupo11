class Saving < ActiveRecord::Base
    belongs_to :account
  
    validates :account, presence: true
    validates :amount, numericality: { greater_than: 0 }
    validates :name, presence: true
  
    after_create :deduct_from_balance
    after_destroy :restore_to_balance
  
    private
  
    def deduct_from_balance
      ActiveRecord::Base.transaction do
        raise "Insufficient funds" if account.balance < amount
  
        account.balance -= amount
        account.save!
      end
    end
  
    def restore_to_balance
      ActiveRecord::Base.transaction do
        account.balance += amount
        account.save!
      end
    end
  end
class Transaction < ActiveRecord::Base
  belongs_to :account

  validates :transaction_type, inclusion: { in: %w[credit debit] }
end

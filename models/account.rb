class Account < ActiveRecord::Base
  belongs_to :user
  has_many :reserves
  has_many :motions

  validates :cvu, :alias, presence: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }
  has_many :source_transactions, class_name: 'Transaction', foreign_key: :source_account_id
end
class Account < ActiveRecord::Base
  belongs_to :user
  has_many :reserves
  has_many :motions

  validates :cvu, presence: true, uniqueness: true, length: { is: 22 }
  validates :account_alias, presence: true, uniqueness: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }
  has_many :source_transactions, class_name: 'Transaction', foreign_key: :source_account_id
end
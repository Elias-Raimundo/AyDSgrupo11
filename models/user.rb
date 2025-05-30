class User < ActiveRecord::Base
  has_secure_password

  belongs_to :person
  has_one :account

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }
end

class User < ActiveRecord::Base
  has_secure_password

  belongs_to :person
  has_one :account

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :person_id, presence: true, uniqueness: true
end

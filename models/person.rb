class Person < ActiveRecord::Base
    has_one :user
  
    validates :name, :surname, :phone_number, presence: true
    validates :dni, presence: true, uniqueness: true
end
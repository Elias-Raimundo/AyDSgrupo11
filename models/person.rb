class Person < ActiveRecord::Base
    has_one :user
  
    validates :name, :surname, :dni, :phone_number, presence: true
end
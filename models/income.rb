class Income < ActiveRecord::Base
    belongs_to :user
    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :source, presence: true
end

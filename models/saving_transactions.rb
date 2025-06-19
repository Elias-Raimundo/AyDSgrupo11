class SavingTransaction < ActiveRecord::Base
    belongs_to :account
  
    validates :name, presence: true
    validates :amount, presence: true, numericality: true
    validates :transaction_type, presence: true, inclusion: { in: ['Ingreso a reserva', 'Retiro de reserva'] }
  end
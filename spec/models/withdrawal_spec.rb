# spec/models/withdrawal_spec.rb
require_relative '../spec_helper'

RSpec.describe Withdrawal do
  let(:user) { User.create!(email: "withdraw@mail.com", password: "123456", person: Person.create!(name: "Mario", surname: "Paz", dni: "55667788", phone_number: "222")) }

  it 'es válido con monto y motivo' do
    withdrawal = Withdrawal.new(user: user, amount: 500.0, reason: "Compra online")
    expect(withdrawal).to be_valid
  end

  it 'es inválido con monto negativo' do
    withdrawal = Withdrawal.new(user: user, amount: -50.0, reason: "Error")
    expect(withdrawal).not_to be_valid
  end

  it 'es inválido sin motivo' do
    withdrawal = Withdrawal.new(user: user, amount: 100.0)
    expect(withdrawal).not_to be_valid
  end
end

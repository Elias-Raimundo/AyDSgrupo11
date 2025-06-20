# spec/models/saving_spec.rb
require_relative '../spec_helper'

RSpec.describe Saving do
  let(:user) { User.create!(email: "save@mail.com", password: "123456", person: Person.create!(name: "Ana", surname: "García", dni: "22345678", phone_number: "456")) }
  let(:account) { Account.create!(user: user, cvu: "1111111111111111111111", account_alias: "alias.saving", balance: 100.0) }

  it 'crea una reserva y descuenta el balance' do
    saving = Saving.create!(account: account, amount: 50.0, name: "Viaje")
    expect(account.reload.balance).to eq(50.0)
  end

  it 'lanza error si no hay fondos suficientes' do
    expect {
      Saving.create!(account: account, amount: 200.0, name: "Imposible")
    }.to raise_error("Insufficient funds")
  end

  it 'devuelve los fondos al eliminar la reserva' do
    saving = Saving.create!(account: account, amount: 30.0, name: "Compras")
    saving.destroy
    expect(account.reload.balance).to eq(100.0)
  end
end

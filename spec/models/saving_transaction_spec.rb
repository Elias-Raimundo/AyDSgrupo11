# spec/models/saving_transaction_spec.rb
require_relative '../spec_helper'

RSpec.describe SavingTransaction do
  let(:account) { Account.create!(user: User.create!(email: "test@test.com", password: "123456", person: Person.create!(name: "Carlos", surname: "Lopez", dni: "33445566", phone_number: "789")), cvu: "2222222222222222222222", account_alias: "alias.tx", balance: 100) }

  it 'es válido con atributos correctos' do
    transaction = SavingTransaction.new(account: account, name: "Reserva", amount: 10, transaction_type: 'Ingreso a reserva')
    expect(transaction).to be_valid
  end

  it 'es inválido si falta el tipo de transacción' do
    transaction = SavingTransaction.new(account: account, name: "Reserva", amount: 10)
    expect(transaction).not_to be_valid
  end
end

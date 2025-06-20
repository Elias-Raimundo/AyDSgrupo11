# spec/models/account_spec.rb
require_relative '../spec_helper'

RSpec.describe Account do
  let(:user) { User.create!(email: "test@mail.com", password: "123456", person: Person.create!(name: "Juan", surname: "Pérez", dni: "12345678", phone_number: "123")) }

  it 'es válido con datos correctos' do
    account = Account.new(user: user, cvu: "1234567890123456789012", account_alias: "mi.cuenta.alias", balance: 0)
    expect(account).to be_valid
  end

  it 'es inválido si el cvu no tiene 22 caracteres' do
    account = Account.new(user: user, cvu: "123", account_alias: "alias", balance: 0)
    expect(account).not_to be_valid
  end

  it 'es inválido si el balance es negativo' do
    account = Account.new(user: user, cvu: "1234567890123456789012", account_alias: "alias", balance: -10)
    expect(account).not_to be_valid
  end
end

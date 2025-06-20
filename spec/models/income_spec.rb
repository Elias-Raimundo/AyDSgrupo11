# spec/models/income_spec.rb
require_relative '../spec_helper'

RSpec.describe Income do
  let(:user) { User.create!(email: "income@mail.com", password: "123456", person: Person.create!(name: "Laura", surname: "Sosa", dni: "44556677", phone_number: "111")) }

  it 'es válido con un monto positivo y fuente presente' do
    income = Income.new(user: user, amount: 1000.0, source: "Trabajo")
    expect(income).to be_valid
  end

  it 'es inválido si el monto es negativo' do
    income = Income.new(user: user, amount: -100.0, source: "Error")
    expect(income).not_to be_valid
  end

  it 'es inválido sin fuente' do
    income = Income.new(user: user, amount: 200.0)
    expect(income).not_to be_valid
  end
end

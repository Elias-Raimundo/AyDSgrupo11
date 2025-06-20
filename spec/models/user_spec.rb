# spec/models/user_spec.rb
require_relative '../spec_helper'

RSpec.describe User do
  let(:person) { Person.create!(name: "Esteban", surname: "Quirós", dni: "66778899", phone_number: "333") }

  it 'es válido con email y contraseña' do
    user = User.new(email: "user@mail.com", password: "123456", person: person)
    expect(user).to be_valid
  end

  it 'es inválido si el email está mal formado' do
    user = User.new(email: "usuario_mal", password: "123456", person: person)
    expect(user).not_to be_valid
  end

  it 'es inválido si la contraseña es demasiado corta' do
    user = User.new(email: "short@mail.com", password: "123", person: person)
    expect(user).not_to be_valid
  end
end

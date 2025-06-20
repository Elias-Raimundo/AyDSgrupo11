# spec/models/person_spec.rb
require_relative '../spec_helper'

RSpec.describe Person do
  it 'es válida con todos los atributos presentes' do
    person = Person.new(name: "Lucía", surname: "Martínez", dni: "77889900", phone_number: "444")
    expect(person).to be_valid
  end

  it 'es inválida si falta el DNI' do
    person = Person.new(name: "Lucía", surname: "Martínez", phone_number: "444")
    expect(person).not_to be_valid
  end

  it 'no permite repetir DNI' do
    Person.create!(name: "Carlos", surname: "Ruiz", dni: "99999999", phone_number: "555")
    duplicate = Person.new(name: "Clon", surname: "Ruiz", dni: "99999999", phone_number: "666")
    expect(duplicate).not_to be_valid
  end
end

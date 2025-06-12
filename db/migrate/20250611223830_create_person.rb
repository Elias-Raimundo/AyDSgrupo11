class CreatePerson < ActiveRecord::Migration[8.0]
  def change
	create_table :people do |t|
      	t.string :name, null: false
      	t.string :surname, null: false
      	t.string :dni, null: false
      	t.string :phone_number, null: false

      	t.timestamps
	end
	add_index :people, :dni, unique: true
  end
end

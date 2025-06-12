# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_11_223952) do
  create_table "accounts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "balance"
    t.string "cvu", null: false
    t.string "account_alias", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_alias"], name: "index_accounts_on_account_alias", unique: true
    t.index ["cvu"], name: "index_accounts_on_cvu", unique: true
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "incomes", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "source", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_incomes_on_user_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "name", null: false
    t.string "surname", null: false
    t.string "dni", null: false
    t.string "phone_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dni"], name: "index_people_on_dni", unique: true
  end

  create_table "savings", force: :cascade do |t|
    t.decimal "monto", precision: 15, scale: 2, null: false
    t.string "motivo", null: false
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_savings_on_account_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "account_id"
    t.decimal "amount", precision: 12, scale: 2
    t.string "transaction_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "person_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["person_id"], name: "index_users_on_person_id", unique: true
  end

  create_table "withdrawals", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "reason", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_withdrawals_on_user_id"
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "incomes", "users"
  add_foreign_key "savings", "accounts"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "users", "people"
  add_foreign_key "withdrawals", "users"
end

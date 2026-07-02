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

ActiveRecord::Schema[8.1].define(version: 2026_07_01_000004) do
  create_table "account_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "firm_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["firm_id", "name"], name: "index_account_types_on_firm_id_and_name", unique: true
    t.index ["firm_id"], name: "index_account_types_on_firm_id"
  end

  create_table "audit_events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "actor_id", null: false
    t.string "actor_type", null: false
    t.bigint "auditable_id", null: false
    t.string "auditable_type", null: false
    t.datetime "created_at", null: false
    t.bigint "firm_id", null: false
    t.string "ip_address"
    t.datetime "occurred_at", null: false
    t.json "payload", null: false
    t.index ["actor_type", "actor_id"], name: "index_audit_events_on_actor"
    t.index ["auditable_type", "auditable_id", "occurred_at"], name: "idx_audit_events_on_auditable"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_events_on_auditable"
    t.index ["firm_id", "occurred_at"], name: "index_audit_events_on_firm_id_and_occurred_at"
    t.index ["firm_id"], name: "index_audit_events_on_firm_id"
  end

  create_table "contacts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "email", null: false
    t.bigint "firm_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "updated_at", null: false
    t.index ["firm_id", "email"], name: "index_contacts_on_firm_id_and_email"
    t.index ["firm_id"], name: "index_contacts_on_firm_id"
  end

  create_table "firms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "holdings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "as_of_date", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "investment_account_id", null: false
    t.decimal "market_value", precision: 18, scale: 2, null: false
    t.decimal "quantity", precision: 18, scale: 6, null: false
    t.string "symbol", null: false
    t.datetime "updated_at", null: false
    t.index ["investment_account_id", "symbol", "as_of_date"], name: "idx_on_investment_account_id_symbol_as_of_date_9ac26383a1", unique: true
    t.index ["investment_account_id"], name: "index_holdings_on_investment_account_id"
  end

  create_table "household_memberships", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_household_memberships_on_contact_id"
    t.index ["household_id", "contact_id"], name: "index_household_memberships_on_household_id_and_contact_id", unique: true
    t.index ["household_id"], name: "index_household_memberships_on_household_id"
  end

  create_table "households", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "firm_id", null: false
    t.string "name", null: false
    t.bigint "primary_contact_id"
    t.datetime "updated_at", null: false
    t.index ["firm_id"], name: "index_households_on_firm_id"
    t.index ["primary_contact_id"], name: "fk_rails_ee4630e0da"
  end

  create_table "investment_accounts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "account_number", null: false
    t.bigint "account_type_id", null: false
    t.date "as_of_date"
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.decimal "current_value", precision: 18, scale: 2, default: "0.0", null: false
    t.string "custodian"
    t.bigint "firm_id", null: false
    t.bigint "household_id", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["account_type_id"], name: "index_investment_accounts_on_account_type_id"
    t.index ["contact_id"], name: "index_investment_accounts_on_contact_id"
    t.index ["firm_id", "account_number"], name: "index_investment_accounts_on_firm_id_and_account_number", unique: true
    t.index ["firm_id", "contact_id"], name: "index_investment_accounts_on_firm_id_and_contact_id"
    t.index ["firm_id", "household_id"], name: "index_investment_accounts_on_firm_id_and_household_id"
    t.index ["firm_id"], name: "index_investment_accounts_on_firm_id"
    t.index ["household_id"], name: "index_investment_accounts_on_household_id"
  end

  create_table "relationships", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.bigint "firm_id", null: false
    t.bigint "related_contact_id", null: false
    t.string "relationship_type", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id", "related_contact_id"], name: "index_relationships_on_contact_id_and_related_contact_id", unique: true
    t.index ["contact_id"], name: "index_relationships_on_contact_id"
    t.index ["firm_id"], name: "index_relationships_on_firm_id"
    t.index ["related_contact_id"], name: "index_relationships_on_related_contact_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.bigint "firm_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["firm_id"], name: "index_users_on_firm_id"
  end

  add_foreign_key "account_types", "firms"
  add_foreign_key "audit_events", "firms"
  add_foreign_key "contacts", "firms"
  add_foreign_key "holdings", "investment_accounts"
  add_foreign_key "household_memberships", "contacts"
  add_foreign_key "household_memberships", "households"
  add_foreign_key "households", "contacts", column: "primary_contact_id"
  add_foreign_key "households", "firms"
  add_foreign_key "investment_accounts", "account_types"
  add_foreign_key "investment_accounts", "contacts"
  add_foreign_key "investment_accounts", "firms"
  add_foreign_key "investment_accounts", "households"
  add_foreign_key "relationships", "contacts"
  add_foreign_key "relationships", "contacts", column: "related_contact_id"
  add_foreign_key "relationships", "firms"
  add_foreign_key "users", "firms"
end

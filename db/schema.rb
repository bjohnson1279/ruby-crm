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

ActiveRecord::Schema[8.1].define(version: 2026_07_09_000001) do
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

  create_table "calendar_events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "color", default: "blue", null: false
    t.bigint "contact_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "end_at", null: false
    t.bigint "firm_id", null: false
    t.datetime "start_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["contact_id"], name: "index_calendar_events_on_contact_id"
    t.index ["end_at"], name: "index_calendar_events_on_end_at"
    t.index ["firm_id"], name: "index_calendar_events_on_firm_id"
    t.index ["start_at"], name: "index_calendar_events_on_start_at"
    t.index ["user_id"], name: "index_calendar_events_on_user_id"
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

  create_table "notes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "body", null: false
    t.string "category", null: false
    t.bigint "contact_id"
    t.datetime "created_at", null: false
    t.bigint "firm_id", null: false
    t.bigint "household_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["category"], name: "index_notes_on_category"
    t.index ["contact_id"], name: "index_notes_on_contact_id"
    t.index ["firm_id"], name: "index_notes_on_firm_id"
    t.index ["household_id"], name: "index_notes_on_household_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "opportunities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "amount", precision: 18, scale: 2, default: "0.0", null: false
    t.date "closed_at"
    t.bigint "contact_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "firm_id", null: false
    t.bigint "household_id"
    t.string "name", null: false
    t.integer "probability", default: 10, null: false
    t.string "stage", default: "prospecting", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["contact_id"], name: "index_opportunities_on_contact_id"
    t.index ["firm_id"], name: "index_opportunities_on_firm_id"
    t.index ["household_id"], name: "index_opportunities_on_household_id"
    t.index ["stage"], name: "index_opportunities_on_stage"
    t.index ["user_id"], name: "index_opportunities_on_user_id"
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

  create_table "tasks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "assigned_user_id", null: false
    t.datetime "completed_at"
    t.bigint "completed_by_id"
    t.bigint "contact_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date", null: false
    t.bigint "firm_id", null: false
    t.string "priority", default: "medium", null: false
    t.string "status", default: "pending", null: false
    t.string "subject", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_user_id"], name: "index_tasks_on_assigned_user_id"
    t.index ["completed_by_id"], name: "index_tasks_on_completed_by_id"
    t.index ["contact_id"], name: "index_tasks_on_contact_id"
    t.index ["due_date"], name: "index_tasks_on_due_date"
    t.index ["firm_id"], name: "index_tasks_on_firm_id"
    t.index ["status"], name: "index_tasks_on_status"
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

  create_table "workflow_process_steps", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.bigint "firm_id", null: false
    t.string "status", default: "pending", null: false
    t.bigint "task_id"
    t.datetime "updated_at", null: false
    t.bigint "workflow_process_id", null: false
    t.bigint "workflow_template_step_id", null: false
    t.index ["firm_id"], name: "index_workflow_process_steps_on_firm_id"
    t.index ["status"], name: "index_workflow_process_steps_on_status"
    t.index ["task_id"], name: "index_workflow_process_steps_on_task_id"
    t.index ["workflow_process_id"], name: "index_workflow_process_steps_on_workflow_process_id"
    t.index ["workflow_template_step_id"], name: "index_workflow_process_steps_on_workflow_template_step_id"
  end

  create_table "workflow_processes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "completed_at"
    t.bigint "contact_id"
    t.datetime "created_at", null: false
    t.bigint "firm_id", null: false
    t.bigint "household_id"
    t.datetime "started_at", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.bigint "workflow_template_id", null: false
    t.index ["contact_id"], name: "index_workflow_processes_on_contact_id"
    t.index ["firm_id"], name: "index_workflow_processes_on_firm_id"
    t.index ["household_id"], name: "index_workflow_processes_on_household_id"
    t.index ["status"], name: "index_workflow_processes_on_status"
    t.index ["workflow_template_id"], name: "index_workflow_processes_on_workflow_template_id"
  end

  create_table "workflow_template_steps", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "days_to_complete", default: 3, null: false
    t.bigint "default_assigned_user_id", null: false
    t.text "description"
    t.bigint "firm_id", null: false
    t.string "name", null: false
    t.string "priority", default: "medium", null: false
    t.integer "sequence_number", default: 1, null: false
    t.datetime "updated_at", null: false
    t.bigint "workflow_template_id", null: false
    t.index ["default_assigned_user_id"], name: "index_workflow_template_steps_on_default_assigned_user_id"
    t.index ["firm_id"], name: "index_workflow_template_steps_on_firm_id"
    t.index ["workflow_template_id"], name: "index_workflow_template_steps_on_workflow_template_id"
  end

  create_table "workflow_templates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "firm_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["firm_id"], name: "index_workflow_templates_on_firm_id"
  end

  add_foreign_key "account_types", "firms"
  add_foreign_key "audit_events", "firms"
  add_foreign_key "calendar_events", "contacts"
  add_foreign_key "calendar_events", "firms"
  add_foreign_key "calendar_events", "users"
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
  add_foreign_key "notes", "contacts"
  add_foreign_key "notes", "firms"
  add_foreign_key "notes", "households"
  add_foreign_key "notes", "users"
  add_foreign_key "opportunities", "contacts"
  add_foreign_key "opportunities", "firms"
  add_foreign_key "opportunities", "households"
  add_foreign_key "opportunities", "users"
  add_foreign_key "relationships", "contacts"
  add_foreign_key "relationships", "contacts", column: "related_contact_id"
  add_foreign_key "relationships", "firms"
  add_foreign_key "tasks", "contacts"
  add_foreign_key "tasks", "firms"
  add_foreign_key "tasks", "users", column: "assigned_user_id"
  add_foreign_key "tasks", "users", column: "completed_by_id"
  add_foreign_key "users", "firms"
  add_foreign_key "workflow_process_steps", "firms"
  add_foreign_key "workflow_process_steps", "tasks"
  add_foreign_key "workflow_process_steps", "workflow_processes"
  add_foreign_key "workflow_process_steps", "workflow_template_steps"
  add_foreign_key "workflow_processes", "contacts"
  add_foreign_key "workflow_processes", "firms"
  add_foreign_key "workflow_processes", "households"
  add_foreign_key "workflow_processes", "workflow_templates"
  add_foreign_key "workflow_template_steps", "firms"
  add_foreign_key "workflow_template_steps", "users", column: "default_assigned_user_id"
  add_foreign_key "workflow_template_steps", "workflow_templates"
  add_foreign_key "workflow_templates", "firms"
end

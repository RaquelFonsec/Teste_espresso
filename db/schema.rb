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

ActiveRecord::Schema[7.1].define(version: 2024_09_30_233547) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string "company_id"
    t.string "erp"
    t.string "erp_key"
    t.string "erp_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "webhook_url"
    t.string "client_id"
    t.string "app_key"
    t.string "app_secret"
  end

  create_table "companies", force: :cascade do |t|
    t.string "erp"
    t.string "erp_key"
    t.string "erp_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "payables", force: :cascade do |t|
    t.string "account_code"
    t.string "category_code"
    t.string "client_code"
    t.integer "client_id"
    t.decimal "cost"
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "amount"
    t.string "status"
    t.string "categoria"
  end

  create_table "reimbursements", force: :cascade do |t|
    t.integer "company_id"
    t.decimal "value", precision: 10, scale: 2
    t.string "description"
    t.date "due_date"
    t.string "payment_method"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "payable_id"
    t.integer "client_id"
    t.datetime "payment_date"
  end

  create_table "webhook_endpoints", force: :cascade do |t|
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "subscriptions", default: ["*"]
    t.boolean "enabled", default: true
    t.string "company_id"
    t.integer "client_id"
    t.string "event_type"
    t.string "erp"
    t.index ["enabled"], name: "index_webhook_endpoints_on_enabled"
  end

  create_table "webhook_events", force: :cascade do |t|
    t.integer "webhook_endpoint_id", null: false
    t.string "event", null: false
    t.text "payload", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "response", default: {}
    t.string "url"
    t.index ["webhook_endpoint_id"], name: "index_webhook_events_on_webhook_endpoint_id"
  end

  create_table "webhook_subscriptions", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "webhook_endpoint_id", null: false
    t.string "event"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_webhook_subscriptions_on_client_id"
    t.index ["webhook_endpoint_id"], name: "index_webhook_subscriptions_on_webhook_endpoint_id"
  end

  add_foreign_key "webhook_subscriptions", "clients"
  add_foreign_key "webhook_subscriptions", "webhook_endpoints"
end

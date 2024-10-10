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

ActiveRecord::Schema[7.1].define(version: 2024_10_10_124009) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients", force: :cascade do |t|
    t.integer "company_id"
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
    t.boolean "is_valid"
    t.string "message"
    t.string "client_code"
    t.boolean "validated"
    t.string "validation_error"
    t.string "erp_token"
    t.integer "account_id"
    t.integer "retry_attempts"
    t.string "email"
  end

  create_table "companies", force: :cascade do |t|
    t.string "erp"
    t.string "erp_key"
    t.string "erp_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "notification_failures", force: :cascade do |t|
    t.bigint "company_id"
    t.jsonb "payload"
    t.string "error_info"
    t.integer "attempts"
    t.datetime "last_attempted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "client_id"
    t.string "message"
    t.string "status"
    t.string "codigo_lancamento_omie"
    t.string "codigo_lancamento_integracao"
    t.date "data_vencimento"
    t.string "codigo_categoria"
    t.date "data_previsao"
    t.bigint "id_conta_corrente"
    t.decimal "valor_documento"
    t.bigint "codigo_cliente_fornecedor"
  end

  create_table "payables", force: :cascade do |t|
    t.string "account_code"
    t.string "category_code"
    t.string "client_code"
    t.bigint "client_id"
    t.decimal "cost"
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "amount"
    t.string "status"
    t.string "categoria"
    t.string "omie_code"
    t.string "integration_code"
    t.string "status_code"
    t.string "description"
    t.string "codigo_lancamento_integracao"
    t.integer "notification_attempts"
    t.string "erp_key"
    t.string "erp_secret"
  end

  create_table "payment_failures", force: :cascade do |t|
    t.bigint "reimbursement_id", null: false
    t.string "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reimbursement_id"], name: "index_payment_failures_on_reimbursement_id"
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
    t.string "account_code"
    t.string "category_code"
    t.string "erp_key"
    t.string "erp_secret"
    t.string "client_code"
    t.boolean "paid"
    t.decimal "cost", precision: 10, scale: 2
    t.integer "failed_attempts"
    t.string "error_message"
    t.integer "payment_id"
    t.string "code"
    t.string "codigo_lancamento_integracao"
    t.integer "pagar_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "transaction_id"
    t.string "status"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "payment_failures", "reimbursements"
  add_foreign_key "webhook_subscriptions", "clients"
  add_foreign_key "webhook_subscriptions", "webhook_endpoints"
end

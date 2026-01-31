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

ActiveRecord::Schema[8.1].define(version: 2026_01_31_171800) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "holdings", force: :cascade do |t|
    t.decimal "average_price", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.bigint "instrument_id", null: false
    t.decimal "quantity", precision: 20, scale: 8
    t.datetime "updated_at", null: false
    t.bigint "wallet_id", null: false
    t.index ["instrument_id"], name: "index_holdings_on_instrument_id"
    t.index ["wallet_id", "instrument_id"], name: "index_holdings_on_wallet_id_and_instrument_id", unique: true
    t.index ["wallet_id"], name: "index_holdings_on_wallet_id"
  end

  create_table "instrument_metrics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "daily_liquidity", precision: 15, scale: 2
    t.decimal "dy", precision: 5, scale: 2
    t.bigint "instrument_id", null: false
    t.decimal "market_cap", precision: 20, scale: 2
    t.decimal "p_vp", precision: 5, scale: 2
    t.decimal "price", precision: 15, scale: 4, null: false
    t.datetime "recorded_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instrument_id", "recorded_at"], name: "index_instrument_metrics_on_instrument_id_and_recorded_at"
    t.index ["instrument_id"], name: "index_instrument_metrics_on_instrument_id"
  end

  create_table "instruments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "kind"
    t.string "name"
    t.string "ticker"
    t.datetime "updated_at", null: false
    t.index ["ticker"], name: "index_instruments_on_ticker", unique: true
  end

  create_table "strategies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "wallet_id", null: false
    t.index ["wallet_id"], name: "index_strategies_on_wallet_id"
  end

  create_table "strategy_rules", force: :cascade do |t|
    t.string "asset_kind"
    t.datetime "created_at", null: false
    t.decimal "max_percentage", precision: 5, scale: 2
    t.bigint "strategy_id", null: false
    t.datetime "updated_at", null: false
    t.index ["strategy_id"], name: "index_strategy_rules_on_strategy_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "instrument_id", null: false
    t.integer "kind"
    t.datetime "occurred_at"
    t.decimal "price", precision: 15, scale: 2
    t.decimal "quantity", precision: 15, scale: 2
    t.datetime "updated_at", null: false
    t.bigint "wallet_id", null: false
    t.index ["instrument_id"], name: "index_transactions_on_instrument_id"
    t.index ["occurred_at"], name: "index_transactions_on_occurred_at"
    t.index ["wallet_id", "occurred_at"], name: "index_transactions_on_wallet_id_and_occurred_at"
    t.index ["wallet_id"], name: "index_transactions_on_wallet_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "status", default: 1, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "holdings", "instruments"
  add_foreign_key "holdings", "wallets"
  add_foreign_key "instrument_metrics", "instruments"
  add_foreign_key "strategies", "wallets"
  add_foreign_key "strategy_rules", "strategies"
  add_foreign_key "transactions", "instruments"
  add_foreign_key "transactions", "wallets"
  add_foreign_key "wallets", "users"
end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_02_042840) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "text", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["text"], name: "index_addresses_on_text"
  end

  create_table "admins", force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: ""
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "invitation_token", limit: 255
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type", limit: 255
    t.datetime "invitation_created_at"
    t.integer "team_id", null: false
    t.string "name", limit: 255
    t.boolean "site_admin", default: false, null: false
    t.string "api_key"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["invitation_token"], name: "index_admins_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_admins_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["team_id"], name: "index_admins_on_team_id"
  end

  create_table "apps", force: :cascade do |t|
    t.string "smtp_username", limit: 255
    t.string "name", limit: 255
    t.string "smtp_password", limit: 255
    t.string "custom_tracking_domain", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "open_tracking_enabled", default: true, null: false
    t.boolean "click_tracking_enabled", default: true, null: false
    t.text "dkim_private_key"
    t.string "from_domain", limit: 255
    t.boolean "dkim_enabled", default: false, null: false
    t.integer "archived_deliveries_count", default: 0, null: false
    t.integer "team_id"
    t.boolean "cuttlefish", default: false, null: false
    t.boolean "legacy_dkim_selector", default: false, null: false
    t.string "webhook_url"
    t.string "webhook_key", null: false
    t.index ["team_id"], name: "index_apps_on_team_id"
  end

  create_table "click_events", force: :cascade do |t|
    t.integer "delivery_link_id"
    t.text "user_agent"
    t.text "referer"
    t.string "ip", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["delivery_link_id"], name: "index_click_events_on_delivery_link_id"
  end

  create_table "deliveries", force: :cascade do |t|
    t.integer "email_id"
    t.integer "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "sent", default: false, null: false
    t.string "postfix_queue_id", limit: 255
    t.boolean "open_tracked", default: false, null: false
    t.integer "open_events_count", default: 0, null: false
    t.string "status", limit: 255, null: false
    t.integer "app_id"
    t.index ["address_id", "created_at"], name: "index_deliveries_on_address_id_and_created_at"
    t.index ["app_id"], name: "index_deliveries_on_app_id"
    t.index ["created_at", "open_events_count"], name: "index_deliveries_on_created_at_and_open_events_count"
    t.index ["email_id", "address_id"], name: "index_deliveries_on_email_id_and_address_id"
    t.index ["open_tracked", "created_at"], name: "index_deliveries_on_open_tracked_and_created_at"
    t.index ["postfix_queue_id"], name: "index_deliveries_on_postfix_queue_id"
  end

  create_table "delivery_links", force: :cascade do |t|
    t.integer "delivery_id", null: false
    t.integer "link_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "click_events_count", default: 0, null: false
    t.index ["delivery_id"], name: "index_delivery_links_on_delivery_id"
    t.index ["link_id"], name: "index_delivery_links_on_link_id"
  end

  create_table "deny_lists", force: :cascade do |t|
    t.integer "address_id"
    t.integer "caused_by_delivery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "team_id", null: false
    t.index ["team_id"], name: "index_deny_lists_on_team_id"
  end

  create_table "emails", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "from_address_id"
    t.string "message_id", limit: 255
    t.string "data_hash", limit: 255
    t.integer "app_id", null: false
    t.string "subject", limit: 255
    t.boolean "ignore_deny_list", null: false
    t.index ["app_id"], name: "index_emails_on_app_id"
    t.index ["created_at"], name: "index_emails_on_created_at"
    t.index ["from_address_id"], name: "index_emails_on_from_address_id"
    t.index ["message_id"], name: "index_emails_on_message_id"
  end

  create_table "links", force: :cascade do |t|
    t.string "url", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["url"], name: "index_links_on_url"
  end

  create_table "meta_values", force: :cascade do |t|
    t.bigint "email_id", null: false
    t.string "key", null: false
    t.string "value", null: false
    t.index ["email_id", "key"], name: "index_meta_values_on_email_id_and_key", unique: true
    t.index ["email_id"], name: "index_meta_values_on_email_id"
  end

  create_table "open_events", force: :cascade do |t|
    t.integer "delivery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "user_agent"
    t.text "referer"
    t.string "ip", limit: 255
    t.string "ua_family", limit: 255
    t.string "ua_version", limit: 255
    t.string "os_family", limit: 255
    t.string "os_version", limit: 255
    t.index ["delivery_id"], name: "index_open_events_on_delivery_id"
  end

  create_table "postfix_log_lines", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "time", null: false
    t.string "relay", limit: 255, null: false
    t.string "delay", limit: 255, null: false
    t.string "delays", limit: 255, null: false
    t.string "dsn", limit: 255, null: false
    t.text "extended_status", null: false
    t.integer "delivery_id", null: false
    t.index ["delivery_id"], name: "index_postfix_log_lines_on_delivery_id"
    t.index ["time", "delivery_id"], name: "index_postfix_log_lines_on_time_and_delivery_id"
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "emails", "addresses", column: "from_address_id", name: "emails_from_address_id_fk"
  add_foreign_key "emails", "apps", name: "emails_app_id_fk", on_delete: :cascade
  add_foreign_key "meta_values", "emails"
  add_foreign_key "postfix_log_lines", "deliveries", name: "postfix_log_lines_delivery_id_fk", on_delete: :cascade
end

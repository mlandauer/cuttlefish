# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20130418054241) do

  create_table "addresses", force: true do |t|
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["text"], name: "index_addresses_on_text"

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "deliveries", force: true do |t|
    t.integer  "email_id"
    t.integer  "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sent",              default: false, null: false
    t.string   "postfix_queue_id"
    t.boolean  "open_tracked",      default: false, null: false
    t.string   "open_tracked_hash"
    t.integer  "open_events_count", default: 0,     null: false
  end

  add_index "deliveries", ["postfix_queue_id"], name: "index_deliveries_on_postfix_queue_id"

  create_table "emails", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "from_address_id"
    t.string   "message_id"
    t.string   "data_hash"
    t.string   "status",          default: "not_sent", null: false
  end

  add_index "emails", ["created_at"], name: "index_emails_on_created_at"
  add_index "emails", ["status"], name: "index_emails_on_status"

  create_table "open_events", force: true do |t|
    t.integer  "delivery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "user_agent"
  end

  create_table "postfix_log_lines", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "time"
    t.string   "relay"
    t.string   "delay"
    t.string   "delays"
    t.string   "dsn"
    t.text     "extended_status"
    t.integer  "delivery_id"
  end

  add_index "postfix_log_lines", ["time"], name: "index_postfix_log_lines_on_time"

end

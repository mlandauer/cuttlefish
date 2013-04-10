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

ActiveRecord::Schema.define(version: 20130410153952) do

  create_table "addresses", force: true do |t|
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
  end

  create_table "emails", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "from_address_id"
    t.string   "postfix_queue_id"
    t.string   "message_id"
    t.string   "data_hash"
    t.string   "delivery_status",  default: "unknown", null: false
  end

  add_index "emails", ["created_at"], name: "index_emails_on_created_at"
  add_index "emails", ["delivery_status"], name: "index_emails_on_delivery_status"
  add_index "emails", ["postfix_queue_id"], name: "index_emails_on_postfix_queue_id"

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

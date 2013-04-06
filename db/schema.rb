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

ActiveRecord::Schema.define(version: 20130406061755) do

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

  create_table "email_addresses", force: true do |t|
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_recipients", force: true do |t|
    t.integer  "email_id"
    t.integer  "email_address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emails", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "from_address_id"
    t.string   "postfix_queue_id"
    t.boolean  "delivered"
  end

  create_table "postfix_log_lines", force: true do |t|
    t.text     "text"
    t.integer  "email_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "time"
  end

  create_table "to_addresses_emails", force: true do |t|
    t.integer  "email_id"
    t.integer  "email_address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

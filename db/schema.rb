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

ActiveRecord::Schema.define(version: 20160329234658885) do

  create_table "readings", force: :cascade do |t|
    t.integer  "hive_id"
    t.integer  "bot_id"
    t.integer  "bot_uptime"
    t.integer  "bot_temp"
    t.integer  "bot_humidity"
    t.integer  "brood_temp"
    t.integer  "brood_humidity"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "hive_lbs"
    t.string   "hourly_group_key"
    t.string   "daily_group_key"
  end

  add_index "readings", ["daily_group_key", "hive_id"], name: "index_readings_on_daily_group_key_and_hive_id"
  add_index "readings", ["hourly_group_key", "hive_id"], name: "index_readings_on_hourly_group_key_and_hive_id"

end

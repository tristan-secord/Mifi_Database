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

ActiveRecord::Schema.define(version: 20170113025408) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "devices", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "device_id"
    t.string   "device_type"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "networks", force: :cascade do |t|
    t.string   "name"
    t.string   "password_hash"
    t.string   "password_salt"
    t.boolean  "discoverable"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "bssid"
  end

  create_table "networks_users", id: false, force: :cascade do |t|
    t.integer "network_id", null: false
    t.integer "user_id",    null: false
    t.index ["network_id", "user_id"], name: "index_networks_users_on_network_id_and_user_id", using: :btree
    t.index ["user_id", "network_id"], name: "index_networks_users_on_user_id_and_network_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.boolean  "email_verification", default: false
    t.string   "verification_code"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "api_authtoken"
    t.datetime "authtoken_expiry"
  end

end

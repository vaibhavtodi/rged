# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 4) do

  create_table "countries", :force => true do |t|
    t.string "name"
  end

  create_table "department_versions", :force => true do |t|
    t.integer "department_id"
    t.integer "country_id"
    t.integer "version_a"
    t.string  "name"
  end

  create_table "departments", :force => true do |t|
    t.integer "parent_id"
    t.integer "country_id"
    t.integer "version_a"
    t.integer "lft"
    t.integer "rgt"
    t.string  "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

end

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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101004075947) do

  create_table "filters", :force => true do |t|
    t.string   "params_string", :limit => 2048, :null => false
    t.string   "sha1",          :limit => 40,   :null => false
    t.string   "title"
    t.integer  "user_id",                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "filters", ["sha1"], :name => "index_filters_on_sha1", :unique => true
  add_index "filters", ["user_id"], :name => "index_filters_on_user_id"

  create_table "persistents", :id => false, :force => true do |t|
    t.string "key"
    t.string "value"
  end

  add_index "persistents", ["key"], :name => "index_persistents_on_key", :unique => true

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id",                  :null => false
    t.integer  "filter_id",                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "key",         :limit => 8, :null => false
    t.datetime "accessed_at"
  end

  add_index "subscriptions", ["key"], :name => "index_subscriptions_on_key", :unique => true
  add_index "subscriptions", ["user_id", "filter_id"], :name => "index_subscriptions_on_user_id_and_filter_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "identifier", :limit => 2048, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["identifier"], :name => "index_users_on_identity", :unique => true

end

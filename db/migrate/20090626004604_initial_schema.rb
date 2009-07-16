class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table "persistents", :id => false do |t|
      t.string "key"
      t.string "value"
    end
    add_index "persistents", "key", :unique => true
    execute("INSERT INTO persistents (key, value) VALUES ('secret', '#{Digest::SHA1.hexdigest(Time.now.to_s)}')")

    create_table "users" do |t|
      t.string "identity", :limit => 2048, :null => false
      t.string "name"
      t.timestamps
    end
    add_index "users", "identity", :unique => true
    add_index "users", "name", :unique => true

    create_table "filters" do |t|
      t.string "params_string", :limit => 2048, :null => false
      t.string "sha1", :limit => 40, :null => false
      t.string "title"
      t.integer "user_id", :null => false
      t.timestamps
    end
    add_index "filters", "sha1", :unique => true
    add_index "filters", "user_id"

    create_table "subscriptions" do |t|
      t.integer "user_id", :null => false
      t.integer "filter_id", :null => false
      t.string "key", :limit => 8, :null => false
      t.datetime "accessed_at"
      t.timestamps
    end
    add_index "subscriptions", ["user_id", "filter_id"], :unique => true
    add_index "subscriptions", "key", :unique => true
  end

  def self.down
    drop_table "subscriptions"
    drop_table "filters"
    drop_table "users"
    drop_table "persistents"
  end
end

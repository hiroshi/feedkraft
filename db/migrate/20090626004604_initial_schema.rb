class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table "users" do |t|
      t.string "identity", :limit => 2048, :null => false
      t.string "name"
      t.timestamp
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
      t.timestamps
    end
    add_index "subscriptions", ["user_id", "filter_id"], :unique => true
  end

  def self.down
    drop_table "subscriptions"
    drop_table "filters"
    drop_table "users"
  end
end

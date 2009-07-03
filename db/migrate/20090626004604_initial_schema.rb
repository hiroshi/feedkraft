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
      t.string "sha1", :limit => 30, :null => false
      t.string "title"
      t.integer "user_id", :null => false
      t.timestamps
    end
    add_index "filters", "sha1", :unique => true
    add_index "filters", "user_id"
  end

  def self.down
    drop_table "filters"
    drop_table "users"
  end
end

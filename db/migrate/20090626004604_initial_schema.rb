class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table "users" do |t|
      t.string "identity", :limit => 2048, :null => false
      t.string "name"
      t.timestamp
    end
    add_index "users", "identity", :unique => true
  end

  def self.down
    drop_table "users"
  end
end

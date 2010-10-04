class AlterUserForTwitterOauth < ActiveRecord::Migration
  def self.up
    change_table "users" do |t|
      t.rename "identity", "identifier"
      t.remove "name"
    end
  end

  def self.down
    change_table "users" do |t|
      t.rename "identifier", "identity"
      t.string "name"
    end
  end
end

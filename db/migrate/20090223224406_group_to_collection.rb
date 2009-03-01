class GroupToCollection < ActiveRecord::Migration
  def self.up
		rename_table :groups, :collections

  end

  def self.down
		rename_table  :collections,:groups
  end
end

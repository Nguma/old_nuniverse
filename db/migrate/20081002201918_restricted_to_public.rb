class RestrictedToPublic < ActiveRecord::Migration
  def self.up
		rename_column :taggings, :restricted, :public
  end

  def self.down
		rename_column :taggings, :public, :restricted
  end
end

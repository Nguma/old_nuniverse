class AddDeltaIndexes < ActiveRecord::Migration
  def self.up
		add_column :nuniverses, :delta, :boolean, :default => false
		add_column :connections, :delta, :boolean, :default => false
		add_column :images, :delta, :boolean, :default => false
		add_column :locations, :delta, :boolean, :default => false
		add_column :bookmarks, :delta, :boolean, :default => false
		add_column :users, :delta, :boolean, :default => false
  end

  def self.down
		remove_column :nuniverses, :delta
		remove_column :connections, :delta
		remove_column :images, :delta
		remove_column :locations, :delta
		remove_column :bookmarks, :delta
		remove_column :users, :delta
  end
end

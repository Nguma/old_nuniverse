class UpdateStates < ActiveRecord::Migration
  def self.up
		add_column :bookmarks, :active, :boolean, :default => 0
		add_column :videos, :active, :boolean, :default => 0
		add_column :images, :active, :boolean, :default => 0
		add_column :users, :active, :boolean, :default => 0
		
		rename_column :nuniverses, :state, :active
		change_column :nuniverses, :active, :boolean, :default => 0
		
		rename_column :stories, :state, :active
		change_column :stories, :active, :boolean, :default => 0
  end

  def self.down
		remove_column :bookmarks, :active
		remove_column :videos, :active
		remove_column :images, :active
		remove_column :users, :active
		
		rename_column :nuniverses, :active, :state
		rename_column :stories, :active, :state
		
		change_column :stories, :state, :string, :default => "pending"
		change_column :nuniverses, :state, :string, :default => "pending"
  end
end

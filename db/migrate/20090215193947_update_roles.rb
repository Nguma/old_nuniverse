class UpdateRoles < ActiveRecord::Migration
  def self.up
		remove_column :users, :role
		add_column :users, :membership_id, :integer, :default => 4
		rename_table :roles, :memberships
  end

  def self.down
		remove_column :users, :membership_id
		add_column :users, :roles, :integer, :default => 4
  end
end

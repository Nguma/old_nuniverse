class UpdatePermissions2 < ActiveRecord::Migration
  def self.up
		remove_column :permissions, :tags
		rename_column :permissions, :grantor_id, :group_id
		rename_column :permissions, :granted_id, :user_id
  end

  def self.down
		add_column :permissions, :tags,  :string
		rename_column :permissions,  :group_id, :grantor_id
		rename_column :permissions,  :user_id, :granted_id	
  end
end
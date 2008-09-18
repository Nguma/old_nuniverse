class UpdatePermissions < ActiveRecord::Migration
  def self.up
		remove_column :permissions, :tagging_id
		remove_column :permissions, :user_id
		add_column :permissions, :grantor_id, :integer
		add_column :permissions, :granted_id, :integer
		add_index :permissions, [:grantor_id, :granted_id, :tags], :unique => true, :name => "from_to_tags"
  end

  def self.down
		remove_column :permissions, :grantor_id
		remove_column :permissions, :granted_id
		remove_index :permissions, :name => "from_to_tag"
		add_column :permissions, :tagging_id, :integer
		add_column :permissions, :user_id, :integer
  end
end

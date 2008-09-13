class AddPermissionTags < ActiveRecord::Migration
  def self.up
		add_column :permissions, :tags, :string
  end

  def self.down
		remove_column :permissions, :tags
  end
end

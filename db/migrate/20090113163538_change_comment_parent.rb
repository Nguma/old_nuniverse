class ChangeCommentParent < ActiveRecord::Migration
  def self.up
		rename_column :comments, :tag_id, :parent_id
		add_column :comments, :parent_type, :string
		
		add_index :comments, [:parent_id, :parent_type], :name => :parent_index
  end

  def self.down
		remove_index :comments, :parent_index
		remove_column :comments, :parent_type
		rename_column :comments, :parent_id, :tag_id
  end
end

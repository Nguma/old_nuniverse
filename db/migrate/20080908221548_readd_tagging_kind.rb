class ReaddTaggingKind < ActiveRecord::Migration
  def self.up
		#add_column :taggings, :kind, :string
		remove_index :taggings, [:subject_id, :object_id, :user_id]
		add_index :taggings, [:subject_id, :object_id, :user_id, :description], :unique => true
  end

  def self.down
		add_index :taggings, [:subject_id, :object_id, :user_id], :unqiue => true
		remove_column :taggings, :kind
  end
end

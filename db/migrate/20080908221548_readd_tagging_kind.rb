class ReaddTaggingKind < ActiveRecord::Migration
  def self.up
		#add_column :taggings, :kind, :string
		#remove_index :taggings, [:subject_id, :object_id, :user_id]
		add_index :taggings, [:subject_id, :user_id, :kind]
		add_index :taggings, [:subject_id, :user_id, :object_id, :kind], :unique => true, :name => 'unique_entries_index'
  end

  def self.down
		add_index :taggings, [:subject_id, :object_id, :user_id], :unique => true
		#remove_column :taggings, :kind
		remove_index "unqiue_entries_index"
  end
end

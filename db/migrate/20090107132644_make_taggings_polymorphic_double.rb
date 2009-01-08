class MakeTaggingsPolymorphicDouble < ActiveRecord::Migration
  def self.up
		add_column :taggings, :tag_type, :string, :default => 'Tag'
		remove_index :taggings, :name => "unique_index"
		add_index :taggings, [:taggable_id, :taggable_type, :tag_id, :tag_type], :unique => true, :name => "unique_index"
  end

  def self.down
		remove_index :taggings, :name => "unique_index"
		add_index :taggings, [:taggable_id, :taggable_type, :tag_id], :unique => true, :name => "unique_index"
		
  end
end

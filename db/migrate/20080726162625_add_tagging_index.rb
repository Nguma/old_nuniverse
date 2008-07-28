class AddTaggingIndex < ActiveRecord::Migration
  def self.up
		add_index :taggings, [:object_id, :path, :user_id], :unique => true
	end

  def self.down
	
  end
end

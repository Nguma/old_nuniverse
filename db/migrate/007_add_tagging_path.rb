class AddTaggingPath < ActiveRecord::Migration
  def self.up
		add_column :taggings, :path, :string
  end

  def self.down
		reove_column	:taggings, :path
  end
end

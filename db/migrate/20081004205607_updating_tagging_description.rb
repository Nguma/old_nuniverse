class UpdatingTaggingDescription < ActiveRecord::Migration
  def self.up
		change_column :taggings, :description, :text, :default => ""
  end

  def self.down
		change_column :taggings, :description, :string
  end
end

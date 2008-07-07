class AddTagDescription < ActiveRecord::Migration
  def self.up
		add_column :tags, :description, :text, :default => ""
  end

  def self.down
		remove_column :tags, :description
  end
end

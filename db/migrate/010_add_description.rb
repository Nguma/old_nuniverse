class AddDescription < ActiveRecord::Migration
  def self.up
		add_column :taggings, :description, :string, :default => ""
  end

  def self.down
		remove_column :taggings, :description
  end
end

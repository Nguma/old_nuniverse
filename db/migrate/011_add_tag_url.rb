class AddTagUrl < ActiveRecord::Migration
  def self.up
		add_column :tags, :url, :string
  end

  def self.down
		remove_column :tags, :url
  end
end

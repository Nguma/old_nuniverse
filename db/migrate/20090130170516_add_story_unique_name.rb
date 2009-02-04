class AddStoryUniqueName < ActiveRecord::Migration
  def self.up
		add_column :stories, :unique_name, :string
  end

  def self.down
		remove_column :stories, :unique_name
  end
end

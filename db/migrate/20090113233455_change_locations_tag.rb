class ChangeLocationsTag < ActiveRecord::Migration
  def self.up
		remove_column :locations, :tag_id
		add_column :locations, :active, :boolean, :default => 0
  end

  def self.down
		remove_column :locations, :active
		add_column :locations, :tag_id, :integer
  end
end

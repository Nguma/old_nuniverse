class AddDeltaIndexToTags < ActiveRecord::Migration
  def self.up
		add_column :tags, :delta, :boolean, :default => false
		add_index :tags, :delta
  end

  def self.down
		remove_index :delta
		remove_column :delta
  end
end

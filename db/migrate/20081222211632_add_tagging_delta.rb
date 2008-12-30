class AddTaggingDelta < ActiveRecord::Migration
  def self.up
		add_column :taggings, :delta, :boolean, :default => 0
		add_column :polycos, :delta, :boolean, :default => 0
  end

  def self.down
		remove_column :taggings, :delta
		remove_column :polycos, :delta
  end
end

class AddDeltaIndexToComments < ActiveRecord::Migration
  def self.up
		add_column :comments, :delta, :boolean, :default => false
  end

  def self.down
		remove_column :comments, :delta
	end
end

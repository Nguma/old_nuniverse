class AddDeltaIndexToFact < ActiveRecord::Migration
  def self.up
		add_column :facts, :delta, :boolean, :default => 0
  end

  def self.down
		remove_column :facts, :delta, :boolean, :default => 0
  end
end

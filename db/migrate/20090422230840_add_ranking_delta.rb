class AddRankingDelta < ActiveRecord::Migration
  def self.up
		add_column :rankings, :delta, :boolean, :default => false
  end

  def self.down
		remove_column :rankings, :delta
  end
end

class AddPendingStates < ActiveRecord::Migration
  def self.up
		add_column :nuniverses, :state, :string, :default => "pending"
		add_index :nuniverses, :state
  end

  def self.down
		remove_index :nuniverses, :state
		remove_column :nuniverses, :state
  end
end

class AddRedirectToNuniverse < ActiveRecord::Migration
  def self.up
		add_column :nuniverses, :redirect_id, :integer
		add_index :nuniverses, :redirect_id
  end

  def self.down
		remove_column :nuniverses, :redirect_id
		remove_index :nuniverses, :redirect_id
  end
end

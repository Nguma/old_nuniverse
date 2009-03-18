class AddIsUniqueColumnToNuniverses < ActiveRecord::Migration
  def self.up
		add_column :nuniverses, :is_unique, :boolean, :default => 1
  end

  def self.down
		remove_column :nuniverses, :is_unique
  end
end

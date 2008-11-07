class AddListsLookups < ActiveRecord::Migration
  def self.up
		add_column :lists, :lookup, :string
  end

  def self.down
		remove_column :lists, :lookup
  end
end

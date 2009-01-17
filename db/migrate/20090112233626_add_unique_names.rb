class AddUniqueNames < ActiveRecord::Migration
  def self.up
		add_column :nuniverses, :unique_name, :string
		
		
		add_index :nuniverses, :unique_name, :unique => true
  end

  def self.down
  end
end

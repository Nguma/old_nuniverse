class CreateRoles < ActiveRecord::Migration
  def self.up
		create_table :roles do |t|
			t.column :name, :string
			t.column :max_connections, :integer
		end 
		change_column :users, :role, :integer
  end

  def self.down
		drop_table :roles
		change_column :users, :role, :string
  end
end

class CreateRoles < ActiveRecord::Migration
  def self.up
		create_table :roles do |t|
			t.column :name, :string
			t.column :max_connections, :integer
		end 
		change_column :users, :role, :integer, :default => 4
		rename_column :users, :role, :role_id
  end

  def self.down
		drop_table :roles
		change_column :users, :role_id, :string
		rename_column :users, :role_id, :role, :default => "free"
  end
end

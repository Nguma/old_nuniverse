class AddUserState < ActiveRecord::Migration
  def self.up
		
		add_column :users, :state, :string, :null => :no, :default => 'passive'
		add_column :users, :deleted_at, :datetime
		remove_column :users, :user_class
		add_index :users, :login, :unique => true
  end

  def self.down
		remove_column :users, :state
		remove_column :users, :deleted_at
		add_column :users, :user_class, :integer
		drop_index :users, :login
  end
end
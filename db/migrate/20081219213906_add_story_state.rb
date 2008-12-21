class AddStoryState < ActiveRecord::Migration
  def self.up
		add_column :stories, :state, :string, :default => "pending"
		add_index :stories, :state
  end

  def self.down
		remove_index :stories, :state
		remove_column :stories, :state
		
  end
end

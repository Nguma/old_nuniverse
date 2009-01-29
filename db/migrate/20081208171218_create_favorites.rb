class CreateFavorites < ActiveRecord::Migration
  def self.up
		create_table :favorites do |t|
			t.column :connection_id, :integer
			t.column :user_id, :integer
			t.timestamps
		end
		
		add_index :favorites, [:connection_id, :user_id], :unique => true
  end

  def self.down
		drop_table :favorites
  end
end

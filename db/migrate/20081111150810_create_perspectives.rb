class CreatePerspectives < ActiveRecord::Migration
  def self.up
    create_table :perspectives do |t|
			t.column :user_id, :integer
			t.column :tag_id, :integer
			t.column :favorite, :integer, :default => 0
      t.timestamps
    end

		add_index :perspectives, [:user_id, :tag_id], :unique => true
		add_index :perspectives, [:user_id]
		add_index :perspectives, [:user_id, :favorite]
  end

  def self.down
    drop_table :perspectives
  end
end

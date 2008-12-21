class CreateStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
			t.column :name, :string
			t.column :author_id, :integer
			t.column :parent_id, :integer
			t.column :public, :boolean, :default => 1
      t.timestamps
    end
		add_index :stories, :author_id
  end

  def self.down
    drop_table :stories
  end
end

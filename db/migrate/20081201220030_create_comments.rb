class CreateComments < ActiveRecord::Migration
  def self.up
		create_table :comments do |t|
			t.column :user_id, :integer
			t.column :title, :string
			t.column :body, :text
			t.column :tag_id, :integer
			t.timestamps
		end
		add_index :comments, :user_id
		add_index :comments, :tag_id
  end

  def self.down
		drop_table :comments
  end
end

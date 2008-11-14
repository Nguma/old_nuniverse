class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
			t.column :name, :string
			t.column :tag_id, :integer
			t.column :user_id, :integer
      t.timestamps
    end

		add_index :groups, [:tag_id]
		add_index :groups, [:name, :user_id], :unique => true
  end

  def self.down
    drop_table :groups
  end
end

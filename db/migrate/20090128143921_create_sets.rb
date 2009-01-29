class CreateSets < ActiveRecord::Migration
  def self.up
    create_table :sets do |t|
			t.column :name, :string
			t.column :unique_name, :string
			t.column :parent_id, :integer
			t.column :private, :boolean
			t.column :editable, :boolean
			t.column :rankable, :boolean
			t.column :description, :text
      t.timestamps
    end

		add_index :sets, :parent_id
		add_index :sets, [:parent_id, :unique_name]
  end

  def self.down
    drop_table :sets
  end
end

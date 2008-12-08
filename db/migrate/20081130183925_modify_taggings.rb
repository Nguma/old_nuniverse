class ModifyTaggings < ActiveRecord::Migration
  def self.up
		drop_table :taggings
		create_table :taggings do |t|
			t.column :predicate, :string
			t.column :taggable_id, :integer
			t.column :taggable_type, :string
			t.timestamps
		end
		add_index [:taggable_id, :taggable_type, :predicate], :unique => true
		add_index :predicate
		add_index [:taggable_id, :taggable_type]
  end

  def self.down
		
  end
end

class ModifyTaggings < ActiveRecord::Migration
  def self.up
		drop_table :taggings
		create_table :taggings, :primary_key => nil do |t|
			t.column :kind, :string
			t.column :connection_id, :integer
			t.timestamps
		end
		add_index [:connection_id, :kind], :unique => true
		add_index :kind
		add_index :connection_id
  end

  def self.down
		
  end
end

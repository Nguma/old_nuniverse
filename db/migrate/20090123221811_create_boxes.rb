class CreateBoxes < ActiveRecord::Migration
  def self.up
		create_table :boxes do |t|
			t.column :name, :integer
			t.column :unique_name, :string
			t.column :x, :integer
			t.column :y, :integer
			t.column :width, :integer
			t.column :height, :integer
			t.column :mode, :string
			t.column :parent_id, :integer
			t.column :parent_type, :string
			t.timestamps
		end
		
	
  end

  def self.down
  end
end

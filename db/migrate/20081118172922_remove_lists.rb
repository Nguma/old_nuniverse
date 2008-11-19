class RemoveLists < ActiveRecord::Migration
  def self.up
		drop_table :lists
  end

  def self.down
		create_table :lists do |t|
			t.column	:label, :string
			t.column	:creator_id, :integer
			t.column	:tag_id,	:integer
      t.timestamps
    end

		add_index	:lists, [:creator_id, :label]
  end
end

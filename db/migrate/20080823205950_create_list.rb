class CreateList < ActiveRecord::Migration
  def self.up
	 create_table :lists do |t|
			t.column	:label, :string
			t.column	:creator_id, :integer
			t.column	:tag_id,	:integer
      t.timestamps
    end

		add_index	:lists, [:creator_id, :label]
  end

  def self.down
		drop_table :lists
  end
end

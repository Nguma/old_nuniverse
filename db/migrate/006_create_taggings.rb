class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t|
			t.integer :subject_id
			t.integer	:object_id
			t.integer	:user_id
      t.timestamps
    end

		add_index :taggings, :subject_id
		add_index :taggings, :object_id
		add_index :taggings, :user_id
  end

  def self.down
    drop_table :taggings
  end
end

class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
			t.column	:content, :string
      t.timestamps
    end

		add_index :tags, [:content]
  end

  def self.down
    drop_table :tags
  end
end

class AddTagsKind < ActiveRecord::Migration
  def self.up
		add_column :tags, :kind, :string
		add_index :tags, [:kind, :content]
  end

  def self.down
		remove_column :tags, :kind
  end
end

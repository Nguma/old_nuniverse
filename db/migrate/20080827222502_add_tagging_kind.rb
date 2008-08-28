class AddTaggingKind < ActiveRecord::Migration
  def self.up
		add_column :taggings, :kind, :string
  end

  def self.down
		remove_column :taggings, :kind, :string
  end
end

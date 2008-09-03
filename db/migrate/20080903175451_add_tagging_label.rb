class AddTaggingLabel < ActiveRecord::Migration
  def self.up
		add_column :taggings, :label, :string
  end

  def self.down
		remove_column :taggings, :label
  end
end

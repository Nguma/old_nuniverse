class MakeCollectionsParentPolymorphic < ActiveRecord::Migration
  def self.up
		add_column :collections, :parent_type, :string
  end

  def self.down
		remove_column :collections, :parent_type
  end
end

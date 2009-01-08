class TagsLabelToName < ActiveRecord::Migration
  def self.up
		rename_column :tags, :label, :name
  end

  def self.down
		rename_column :tags, :name, :label
  end
end

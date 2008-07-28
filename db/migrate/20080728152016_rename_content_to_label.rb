class RenameContentToLabel < ActiveRecord::Migration
  def self.up
		rename_column :tags, :content, :label
  end

  def self.down
		rename_column :tags, :label, :content
  end
end

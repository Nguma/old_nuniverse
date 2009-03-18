class AddImagesUrl < ActiveRecord::Migration
  def self.up
		remove_column :images, :tag_id
		add_column :images, :url, :string
		add_index :images, :url
  end

  def self.down
		add_column :images, :tag_id, :integer
  end
end

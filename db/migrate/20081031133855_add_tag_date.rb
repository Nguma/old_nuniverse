class AddTagDate < ActiveRecord::Migration
  def self.up
    add_column :tags, :related_date, :datetime
  end

	

  def self.down
    remove_column :tags
  end
end

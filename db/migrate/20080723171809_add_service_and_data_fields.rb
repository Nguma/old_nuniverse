class AddServiceAndDataFields < ActiveRecord::Migration
  def self.up
    add_column :tags, :service, :string
    add_column :tags, :data,    :string, :limit => 1024 * 4
  end

  def self.down
    remove_column :tags, :service
    remove_column :tags, :data
  end
end

class AddRestrictedFlagToTaggings < ActiveRecord::Migration
  def self.up
    add_column :taggings, :restricted, :boolean, :default => false
    
    add_index :taggings, :restricted
  end

  def self.down
    remove_column :taggings, :restricted
  end
end

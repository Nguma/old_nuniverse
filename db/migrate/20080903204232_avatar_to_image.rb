class AvatarToImage < ActiveRecord::Migration
  def self.up
		rename_table :avatars, :images
  end

  def self.down
		rename_table :images, :avatars
  end
end

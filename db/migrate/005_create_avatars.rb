class CreateAvatars < ActiveRecord::Migration
  def self.up
    create_table :avatars do |t|
      t.integer :size
      t.string  :content_type
      t.string  :filename
      t.integer :height
      t.integer :width
      t.integer :parent_id
      t.string  :thumbnail
      t.integer :tag_id
      t.timestamps
    end
    
    add_index :avatars, :tag_id
    add_index :avatars, :parent_id
  end

  def self.down
    drop_table :avatars
  end
end

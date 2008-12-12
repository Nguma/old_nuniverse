class MakeTagsPolymorphic < ActiveRecord::Migration
  def self.up
	

		
	#	remove_column :tags, :related_date
		
		tags = Tag.find(:all, :conditions => 'taggable_type = "nuniverse"')
		tags.each do |tag|
			n = Nuniverse.create(:name => tag.label)
			tag.taggable_type = "Nuniverse"
			tag.taggable_id = n.id
		end

		tags = Tag.find(:all, :conditions => 'taggable_type = "bookmark"')
		tags.each do |tag|
			n = Bookmark.create(:name => tag.label, :url => tag.url, :service => tag.service )
			tag.taggable_type = "Bookmark"
			tag.taggable_id = n.id
		end	
		
		tags = Tag.find(:all, :conditions => 'taggable_type = "video"')
		tags.each do |tag|
			n = Video.create(:name => tag.label,  :url => tag.url, :service => tag.service )
			tag.taggable_type = "Video"
			tag.taggable_id = n.id
		end
		
		tags = Tag.find(:all, :conditions => 'taggable_type = "image"')
		tags.each do |tag|
			n = Image.find(:filename => tag.label)
			tag.taggable_type = "Image"
			tag.taggable_id = n.id
		end
		
  end

  def self.down
		rename_column :tags, :taggable_type, :kind
		remove_column :tags, :taggable_id
		
		drop_table :nuniverses
		drop_table :bookmarks
		drop_table :locations
		drop_table :videos
  end
end

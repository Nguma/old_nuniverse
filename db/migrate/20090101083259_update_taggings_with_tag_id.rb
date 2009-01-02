class UpdateTaggingsWithTagId < ActiveRecord::Migration
  def self.up
		add_column :taggings, :tag_id, :integer
				
				# taggings = Tagging.find(:all)
				# taggings.each do |tagging|
				# 	t = Tag.find(:first, :conditions => ["label = ?",tagging.predicate])
				# 	t = Tag.create(:label => tagging.predicate) if t.nil?
				# 	tagging.tag_id = t.id
				# 	tagging.save
				# end
		
		
			
		remove_index :taggings, :name => "kind"
		remove_index :taggings, :name => "taggable_id"
		remove_index :taggings, :name => "connection_id"
		
		add_index :taggings, [:taggable_id, :taggable_type, :tag_id], :unique => true, :name => "unique_index"
		add_index :taggings, [:taggable_id, :taggable_type], :name => "taggable_index"
		
		remove_column :taggings, :predicate
  end

  def self.down
	
		add_column :taggings, :predicate, :string
		
		taggings = Tagging.find(:all)
		taggings.each do |tagging|
			tagging.predicate = tagging.tag.label
			tagging.save
		end
		
		
			
		remove_index :taggings, :name => "taggable_index"
		remove_index :taggings, :name => "unique_index"
		
		add_index :taggings, [:predicate], :name => "kind"
		add_index :taggings, [:taggable_id, :taggable_type, :predicate], :name => "taggable_id"
		add_index :taggings, [:taggable_id, :predicate], :name => "connection_id"
		
		remove_column :taggings, :tag_id
  end
end

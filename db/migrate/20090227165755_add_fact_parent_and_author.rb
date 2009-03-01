class AddFactParentAndAuthor < ActiveRecord::Migration
  def self.up
		add_column :facts, :author_id, :integer		
		add_index :facts, :author_id, :name => :author_index		
		# 
				# add_index :facts, :author_id, :name => :author_index
				# add_index :facts, :author_id, :name => :author_index		
				# add_index :facts, :author_id, :name => :author_index
  end

  def self.down
		remove_index :facts, :author_index
		# remove_index :facts, :parent_index
		remove_column :facts, :author_id
		# remove_column :facts, :parent_id
		# remove_column :facts, :parent_type
		# remove_column :facts, :private
  end
end

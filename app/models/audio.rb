class Audio < ActiveRecord::Base
	has_attachment    :content_type => 'application/mp3',
										:path_prefix => "public/attachments",
										:storage => :file_system,
	                  :max_size => 10.megabytes,
	                  :processor => :none
	                   
	validates_as_attachment
end

create_table :nuniverses do |t|
		t.column :name, :string
		t.timestamps
	end
	
	create_table :bookmarks do |t|
		t.column :name, :string
		t.column :url, :string
		t.column :service, :string
		t.timestamps
	end
	
	create_table :locations do |t|
		t.column :name, :string
		t.column :full_address, :string
		t.column :latlng, :string
		t.column :country_id, :integer
		t.column :country_code, :string
		t.timestamps
	end
	
	create_table :videos do |t|
		t.column :name, :string
		t.column :url, :string
		t.column :service, :string
		t.timestamps
	end
	
	add_index :nuniverses, :name
	
	add_column :tags, :taggable_id, :integer
	rename_column :tags, :kind, :taggable_type
	
	add_index :tags, [:taggable_id, :taggable_type]
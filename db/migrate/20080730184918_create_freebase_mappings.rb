class CreateFreebaseMappings < ActiveRecord::Migration
  def self.up
    create_table :freebase_mappings do |t|
      t.string :freebase_type
      t.string :local_type
      t.timestamps
    end
    
    add_index :freebase_mappings, :freebase_type
    add_index :freebase_mappings, :local_type
    
    {
  	  '/music/track'            => "song",
  		'/location/citytown'      => "city",
  		'/music/artist'           => "person",
  		'/music/musical_group'    => "band",
  		'/book/book'              => "book",
  		'/music/album'            => "album",
  		'/people/person'          => "person",
  		'/film/film'              => "movie",
  		'/location/country'       => 'country',
  		'/cvg/computer_videogame' => 'videogame',
  		'/dining/restaurant'      => 'restaurant',
  		'/business/company'       => 'company',
  		'architecture/museum'     => 'museum'
  	}.each do |key, value|
  	  FreebaseMapping.create :freebase_type => key, :local_type => value
	  end
  end

  def self.down
    drop_table :freebase_mappings
  end
end

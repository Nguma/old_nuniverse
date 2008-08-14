module Freebaser
	class Request
		def initialize(params = {})
			@query = Metaweb::Type::Object.search(
			  params[:query],
			  Freebaser::ReverseMappings[params[:type]] || []
			)
		end
		
		
		def find(params)
			Metaweb::Type::Object.find params[:id]
		end
		
		def results
			Freebaser::Response.new(@query).results
		end
	end
	
	class Response
		def initialize(elements)
			@elements = elements
		end
		
		def results
			r = []
			@elements.each do |element|
				r << Freebaser::Result.new(element)
			end
			r
		end
		
	end
	
	Mappings = {
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
		'/structure/location'     => 'museum',
		'/film/film_character'   => 'character',
		'/fictional_universe/fictional_character'  => 'character',
		'/cvg/game_character' => 'character'
		
	}
	
	ReverseMappings = Mappings.keys.inject({}) { |hash,key|
	  hash[Mappings[key]] = key
	  hash
	}
	
	class Result
		attr_accessor :kind, :name, :id
		def initialize(element)
			@id =  element['id']
			@name = element['name']
			@kind = map_kind(element)
		end
		
		def map_kind(element)
			element['type'].reverse.each do |type|
				return Freebaser::Mappings[type] if Freebaser::Mappings.has_key?(type)
			end
			return 'channel'
		end
	end
end
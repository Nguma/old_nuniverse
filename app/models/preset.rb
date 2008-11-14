class Preset 
	def self.find(kind)
		p = []

		Nuniverse::Kind.match(kind).each do |k|
			p << sets[k] unless sets[k].nil?
		end
		
		return [] if p.empty?
		p.flatten.uniq
	end
	
	def self.sets
		{
			"genre" => ['films'],
			"topic" => ["bookmarks","videos","comments"],
			# "user" => ["bookmarks","products","videos","people", "topics"],
			"friend" => ["address","telephone"],
			"person" => ["comments","videos","bookmarks"],
			"location" => ["address","telephone","bookmarks","videos","comments"],
			"restaurant" => ["menu","reviews"],
			"museum" => ["events","artists","artworks","members"],
			"artist" => ["artworks"],
			"artwork" => [],
			"painter" => ["paintings"],
			"painting" => ["painter","creation date","comments"],
			"album" => ["artist","release date","songs","comments","videos"],
			"director" => ["films"],
			"film" => ["genre","authors","actors","directors","producers","characters","products","comments","videos","books"],
			"video" => ["comments"],
			"todo" => ["priority","comments"],
			"company" => ["members","clients","products","comments","news", "bookmarks"],
			"brand" => ["products","comments","videos", "bookmarks"],
			"band" => ["albums","members","songs","products","comments","videos"],
			"musician" => ["albums","songs","products","comments","videos","instruments"],
			"singer" => ["albums","songs","products","comments","videos"],
			"chef" => ["comments","restaurants","recipes","awards","videos"],
			"actor" => ["comments","characters","films","plays","videos"],
			"character" => ["comments","actors","videos","books","products","friends","enemies"],
			"author" => ["books","plays","films","characters","comments","videos"],
			"book" => ["characters","author","products"],
			"recipe" => ["steps","ingredients"],
			"country" => ["cities","regions","address"],
			"continent" => ["countries"],
			"city" => ["address","hotels","museums"],
			"hotel" => ["address","telephone","amenities"],
			"vehicle" => ["brand","manufacturer","videos","sellers"],
			"event" => ["start date","end date","location","comments"],
			"date" => ["events"]
		}
		
	end
end

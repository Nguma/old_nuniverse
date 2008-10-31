module Nuniverse
	# GOOG_GEO_KEY = "ABQIAAAAzMUFFnT9uH0xq39J0Y4kbhTJQa0g3IQ9GZqIMmInSLzwtGDKaBR6j135zrztfTGVOm2QlWnkaidDIQ"
	GOOG_GEO_KEY = "ABQIAAAA8l8NOquAug7TyWVBqeUUKBQEtxNUKhNqH9fVyPPamALnlXdwmxQXyPYD9XOjHMOgc3AuNtDGwMBNHQ"
	
	class Kind
		def initialize
		end
		
		def self.all
			self.list
		end
		
		def self.list
			{
				'loc' => ['location'],
				'per' => ['person'],
				'vid' => ['video'],
				'link' => ['bookmark'],
				'video' => ['video'],
				'place' => ['location'],
				'country' => ['location','country'],
				'city' => ['location','city'],
				'restaurant' => ['location','restaurant'],
				'bar' => ['location','bar'],
				'designer' => ['person','designer'],
				'camera' => ['item','camera'],
				'president' => ['person','president'],
				'director' => ['person','director'],
				'chef' => ['person','chef'],
				'host' => ['person','host'],
				'museum' => ['location','museum'],
				'company' => ['group','company'],
				'team' => ['group','team'],
				'band' => ['group','band'],
				'album' => ['artwork','album'],
				'camera' => ['item','camera'],
				'character' => ['character'],
				'my trip to' => ['location'],
				'trip to' => ['location'],
				'on the way to' => ['location'],
				'event' => ['event'],
				'address' => ['address'],
				'favorite people' => ['favorite','person'],
				'favorite movie' => ['favorite','film'],
				'favorite restraurants' => ['favorite','restaurant'],
				'friend' => ['person','friend'],
				'enemy' => ['person','enemy'],
				'message' => [''],
				'lcoation' => ['location'],
				'lcoatuon' => ['location'],
				'perosn' => ['person'],
				'movie' => ['film'],
				'flick' => ['film'],
				'pro' => ['comment','pro'],
				'con' => ['comment','con'],
				'painting' => ['artwork','painting'],
				'sculpture' => ['artwork','sculpture'],
				'drawing' => ['artwork','drawing'],
				'artowrk' => ['artwork'],
				'country' => ['location','country'],
				'city' => ['location','city'],
				'town' => ['location','city'],
				'continent' => ['location','continent'],
				'planet' => ['location','planet'],
				'dvd' => ['product','dvd'],
				'cd' => ['product','cd'],
				'song' => ['artwork','song'],
				'book' => ['artwork','book'],
				'friend' => ['person','friend'],
				'enemy' => ['person','enemy'],
				'chef' => ['person','chef'],
				'singer' => ['musician','singer'],
				'artist' => ['person','artist'],
				'drummer' => ['musician','drummer'],
				'guitarist' => ['musician','guitarist'],
				'actor' => ['person','actor'],
				'painter' => ['person','artist','painter'],
				'sculptor' => ['person','artist','sculptor'],
				'car' => ['vehicle','car'],
				'truck' => ['vehicle','truck'],
				'bike' => ['vehicle','bike'],
				'plane' => ['vehicle','plane'],
				'menu' => ['dish'],
				'recipe' => ['step'],
				'todo' => ['to do'],
				'tel' => ['telephone']
			}
		end
		
		def self.match(kind_str)
			return if kind_str.nil?
			kind_str.strip.downcase.gsub(/^(add\s(a\s|to\s)?)?(new\s)?/,'').collect {|k| self.list[k.singularize] || k.singularize }.flatten
		end
		
		def self.hash	
			self.list.collect {|kind| Nuniverse::LabelValue.new(kind)}
		end
		
		def self.scan_entry(entry)
			
			# entry.scan(/^(#{self.list.collect {|c| c[0]}.join('|')})?\:?\s?([^#|\[|\]]+)$/)[0]
			
		end
		
		def self.find_tags(input)
			input.singularize.downcase.split(/\s|,/).collect {|c| c.singularize}
		end
		
		def self.analyze(input)
			if pop = input.downcase.match(/\b(a|the|my|some|many|every|all|your|her|his|our)?\b(.+)\b(of|to|at|in)\b(.+)/)
				raise "subject: #{pop[1]}"
			elsif pop = input.downcase.match(/\b(a|the|my|some|many|every|all|your|her|his|our)?\b(.+)\b(.+)\b$/)
				raise "subjects: #{pop[3]}"
			end
		end
		
		
		def self.parse(input)
			input = input.gsub(/\s|,/,"#")
			input = input.downcase.gsub(/\b(a|to|at|in|i|of|my|the|his|her|our|all|some|all|every|each)\b#/,'\1 ')
			input
		end
		
		
		def self.matching_info(kind)
		
			info = self.infos[self.match(kind).split('#').first]
			return info unless info.nil?
			return 'description'
		end
		
		def self.infos
			{
				'person' => ['profession'],
				'artwork' => ['artist'],
				'location' => ['address'],
				'restaurant' => ['address'],
				'museum' => ['address'],
				'album' => ['artist'],
				'item' => 'price'
			}
		end

	end
	
	class LabelValue
		attr_reader :label, :value
		def initialize(label, value = nil)
			@label = label
			@value = value.nil? ? label : value
		end
	end
		
	class Address
		attr_reader :continent, :country, :region, :city, :street_address, :zip, :full_address, :latlng
		def initialize(tag)
			@full_address = tag.property('address')
			@latlng = tag.property('latlng')
			
		end
		
		def coordinates
			Nuniverse::Address.coordinates(@latlng)
		end
		
		def lat
			coordinates[0] rescue nil
		end
		
		def lng
			coordinates[1] rescue nil
		end
		
		def has_coordinates?
			return true if coordinates
			false
		end
		
		def hierarchy
			return Geonamer::Request.new(:service => "hierarchy", :query => full_address) if has_geoname_id?
		end
		
		def scan(query)
			full_address.scan(/##{query}[\s]+([^#|\[|\]]+)*/).to_s rescue nil
		end
		
		def has_geoname_id?
			true if scan("geoname_id")
			false
		end
		
		def self.majors
			['continent', 'country', 'city', 'state', 'region']
		end
		
		def self.find_coordinates(tag)
			if !tag.property('latlng').blank?
				return self.coordinates(tag.property('latlng')) unless nil
			end
			full_address = tag.property('address')
			if full_address.blank? && self.majors.include?(tag.kind)
				full_address = tag.label
			end
			return nil if full_address.blank?
			
			
			gg = Graticule.service(:google).new(GOOG_GEO_KEY).locate(full_address.to_s) rescue nil
			
			if gg
				tag.replace_property("latlng","#{gg.latitude},#{gg.longitude}")
				tag.replace_property("city",gg.locality) unless gg.locality.nil?
				tag.replace_property("zip",gg.postal_code) unless gg.postal_code.nil?
				tag.replace_property("country", gg.country) unless gg.country.nil?
				tag.replace_property("address", gg.to_s)
				tag.replace_property("address_precision",gg.precision.to_s)
				tag.save
				return ([gg.latitude, gg.longitude])
			end
			nil
		end
		
		def self.coordinates(latlng)
			case latlng
			when String
				coords = latlng.split(',')
			when Array
				coords = latlng
			else
				coords = []
			end
			return nil if coords.length != 2
			coords
		end
		

		
		class Error < StandardError; end

	end
	
	def self.tokenize(str)
		str.gsub!(/^(The|a)?(.*)\s\bof\b\s(.*)$\g/,'\3 \2')
		raise str.inspect
	end
	
end
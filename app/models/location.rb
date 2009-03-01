class Location < ActiveRecord::Base
	
	has_many :taggings, :as => :taggable, :dependent => :destroy
	has_many :tags, :through => :taggings, :source => :tag, :source_type => "Tag"
	has_many :contexts, :through => :taggings, :source => :tag, :source_type => "Collection"
	
	has_many :connections, :as => :object, :class_name => "Polyco"
	has_many :nuniverses, :through => :connections, :source => :subject, :source_type => "Nuniverse"

	
	named_scope :gather, lambda {|nuniverses|
			nuniverses.nil? ? {} : {:joins => ["LEFT OUTER JOIN polycos P on P.subject_id = locations.id AND P.subject_type = 'Location'"], :conditions => ["P.object_id IN (?) AND P.object_type = 'Nuniverse'", nuniverses.collect {|c| c.id}]}
		
		}
		
	def find_telephone_numbers
		nuniverses.search :conditions => {:predicate => "tel|telephone"}, :match_mode => :boolean
	end
	
	def lat
		latlng.split(',')[0]
	end
	
	def lng
		latlng.split(',')[1]
	end
	
	def address
		full_address
	end
	
	def self.localize(address, source)
		begin
			@geoloc = Graticule.service(:google).new(GOOG_GEO_KEY).locate(address.to_s)
		
			return Location.new(
			:name => source.name,
			:full_address => "#{@geoloc.street} #{@geoloc.locality} #{@geoloc.region} #{@geoloc.zip} #{@geoloc.country}",
			:latlng => @geoloc.coordinates.join(',')
			)
		rescue
			raise "Error parsing a location from this address: #{address} to source: #{source}"
		end
	end
end
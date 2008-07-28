module Lastfmize
	LAST_FM_URL = "http://ws.audioscrobbler.com/2.0/?api_key=b25b959554ed76058ac220b7b2e0a026"
	class Request
		
		def initialize(params = {})
			@artist = params[:artist]
			@method = params[:method]
			@kind = params[:kind]

		end
		
		def self.response
			uri = "#{LAST_FM_URL}&method=#{@kind}.#{@method}&artist=#{@artist}"
			Lastfmize::Response(Net::HTTP.get_response(URI.parse(uri)))
		end
	end
	
	class Response
		def initialize(response)
			@body = response.body
		end
		
		def xml_items(tag)
			REXML::Document.new(body).elements.to_a("#{tag}")
		end
		
		def events
			events = []
			xml_items("//event").each do |event|
				events << Lastfmize::Event.new(event)
			end
			events
		end
	end
	
	class Event
		attr_reader :venue, :image, :date, :time
		def initialize(xml)
			@venue = new Location(xml.elements["venue"])
			@image = xml.elements["image[@size=medium]"].text
			@date = xml.elements["startDate"].text
			@time = xml.elements["startTime"].text
		end
	end
	
	class Location
		attr_reader :name, :latlng, :address
		def initialize(xml)
			@name = new Location(xml.elements["name"])
			@latlng = xml.elements["location/geo:point/geo:lat"].text+","+xml.elements["geo:point/geo:lng"].text
			@address = xml.elements["location/city"].text+", "+ xml.elements["location/country"].text
		
		end
	end
end
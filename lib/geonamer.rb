module Geonamer
	
	GEO_REST_URL = "http://ws.geonames.org/"
	class Request
	
		def initialize(params = {})
			
		end
	
		def address_info(address)
			uri = "#{GEO_REST_URL}search?q=#{address}"
			call(uri)
		end
	
		def country_infos(params = {})
			uri = "#{GEO_REST_URL}countryInfo?"
			uri << "&country=#{params[:country]}" if params[:country]
			Geonamer::Response.new(call(uri), "//country").results
		end
		
		def weather(params)
			uri = "#{GEO_REST_URL}findNearByWeatherXML?lat=#{params[:lat]}&lng=#{params[:lng]}"

			Geonamer::Response.new(call(uri), "geonames/observation").weather
		end
	
		def call(uri)
			Net::HTTP.get_response(URI.parse(uri))
		end
	end
	
	class Response
		attr_reader :body, :tag

		def initialize(response, tag)
			@body = response.body
			@tag = tag
		end

		def results
			locations = []
			xml_items.each do |xml_item|
				locations << Geonamer::Location.new(xml_item)
			end
			locations
		end
		
		def weather
			observations = []
			xml_items.each do |xml_item|
				observations << Geonamer::Observation.new(xml_item)
			end
			observations.first
		end
		
		def xml_items
			REXML::Document.new(body).elements.to_a("#{tag}")
		end

	end

	class Location
		attr_reader :name, :code, :capital, :latlng
		def initialize(xml)
			@kind = "country"
			@name = xml.elements["countryName"].text
			@code = xml.elements["countryCode"].text
			@capital = xml.elements["capital"].text
			lat = xml.elements["bBoxEast"].text.to_f - xml.elements["bBoxWest"].text.to_f
			lng = xml.elements["bBoxNorth"].text.to_f - xml.elements["bBoxSouth"].text.to_f
			@latlng = "#{@lat},#{@lng}"
		end
	end
	
	class Observation
		attr_reader :temperature, :windspeed, :clouds, :conditions
		def initialize(xml)
			@temperature = (1.8*xml.elements["temperature"].text.to_i)+32
			@windspeed = xml.elements["windSpeed"].text.to_i
			@clouds = xml.elements["clouds"].text
			@clouds = "Sunny" if @clouds == "n/a"
			@conditions = xml.elements["weatherCondition"].text
		end
	end
	
end
module Googleizer
	attr_reader :results
	G_REFERER = 	"http://www.nuniverse.net"
	G_REST_URL = 	"http://ajax.googleapis.com/ajax/services/search"
	DEFAULT_SEARCH_MODE = "web"
	
	class Request
		attr_reader :query, :mode
		def initialize(query, params = {})
			@mode = params[:mode] ||= DEFAULT_SEARCH_MODE
			@query = query
		end
		
		def response
			uri = "#{G_REST_URL}/#{mode}?v=1.0&q=#{query.gsub(" ", "+")}&rsz=large"
			Googleizer::Response.new(Net::HTTP.get_response(URI.parse(uri)),mode)
		end
		
	end

	class Response
		attr_reader :body, :mode
		def initialize(response, mode)
			@body = response.body
			@mode = mode
		end
		
		def results
			items = []
			JSON.parse(@body)['responseData']['results'].each do |item|
				
				items << Tag.new(
				:label => item['titleNoFormatting'],
				:kind => mode_to_kind,
				:service => 'google',
				:description => item['content'],
				:url => url(item) ,
				:data => "#thumbnail #{item['tbUrl'] rescue ''}"
				)
			end
			items 
		end
		
		def url(item)
			return item['playUrl'] if @mode == "video"
			return item['url']
		end
		
		def mode_to_kind
			case @mode
			when "web"
				"bookmark"
			when "images"
				"image"
			when "local"
				"location"
			when "video"
				"video"
			when "news"
				"bookmark"
			else
				"bookmark"
			end
		end
	end
end
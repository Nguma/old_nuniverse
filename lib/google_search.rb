require 'google_ajax'
	
class DoppleGoogler
	attr_reader :results
	G_REFERER = 	"http://localhost:3000"
	G_REST_URL = 	"http://ajax.googleapis.com/ajax/services/search"
	
	def initialize(params = {})
		@results = []
		@default_mode = params[:mode] || "web"
	end
	
	def search(query, params = {})
		mode = params[:mode] || @default_mode
		request_url = "#{G_REST_URL}/#{mode}?v=1.0&q=#{query.gsub(" ", "+")}"
		@response = Net::HTTP.get_response(URI.parse(request_url))
		case @response
			when Net::HTTPSuccess  then JSON(@response.body)
		  else
		    raise @response.error!
		  end
	end
end
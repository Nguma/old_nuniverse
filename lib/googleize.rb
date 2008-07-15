class Googleize
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
			when Net::HTTPSuccess  then parse(@response.body)
		  else
		    raise @response.error!
		  end
	end
	
	def parse(data)
		data = JSON.parse(data)
		#Errors.process(data)
		Results.new(data['responseData'])
	end
	
	class Results < OpenStruct
		def initialize(data)
	     super(data)
	     self.results = results.collect {|data| Result.new(data)}
	     self.cursor = Cursor.new(cursor) if self.cursor
	  end

	 	def count
	     self.cursor.estimatedResultCount
	  end
	end

	class Result < OpenStruct
	  def initialize(data)
	     super(data)
	  end
	end

	class Cursor < OpenStruct
	   def initialize(data)
	     super(data)
	     self.pages = pages.collect {|data| Page.new(data)}
	   end
	end

	class Page < OpenStruct
	   def initialize(data)
	      super(data)
	   end
	end
end
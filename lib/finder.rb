module Finder
	class Search
		class << self
			def find(params)
				"Finder::#{params[:service].camelize}".constantize.new(params).results
			end
		end
	end
	
	class Google
		def initialize(params)
			@query = params[:query]
			@mode = params[:filter] || "web"

		end
		
		def results
			Googleizer::Request.new("#{@query} -amazon.com -ebay.com -youtube.com", :mode => @mode).response.results
		end
	end

	class Nuniverse
		attr_accessor :query, :kind
		def initialize(params)
			
			# parse_query(params[:query])
			@query = params[:query]
			@page = params[:page] || 1
			@per_page = params[:per_page] || 8				
		end

		def results
			Tag.with_label_like(@query).paginate(:page => @page, :per_page => @per_page)
		end
		
		def parse_query(query)
		
		end
	end

	class Amazon
		def initialize(params)
			@query = params[:query]
			@category = params[:filter] || "All"
		end
		
		def results
			Awsomo::Request.new(
				:query => @query, 
				:category => @category
				).response.items
		end
	end

	class Ebay
	end

	class Daylife
		def initialize(params)
			@query = params[:query]
			@mode = params[:filter] || "article"
		end
		
		def results
			Daylife::Request.new(
				:query => @query,
				:mode => @mode,
				:@per_pages => 10
			).results
		end
	end

	class Freebase
		def initialize(params)
		end
		
		def results
			
		end
	end

end
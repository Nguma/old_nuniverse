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
			Googleizer::Request.new("#{@query} -amazon.com -ebay.com -youtube.com", :mode => @mode).response(@extras).results
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
			@kind = params[:kind] || "All"
		end
		
		def results
			Awsomo::Request.new(
				:query => @query, 
				:kind => @kind
				).response.items
		end
	end

	class Ebay
	end
	
	class Yelp
		def initialize(params)
			@location = params[:tag]
			@request_url = "http://api.yelp.com/business_review_search?ywsid=3hJ2kdHDjDaaS17YBzmOzw&term=#{@location.label}&category=#{@location.kind.pluralize}"
			@request_url << "&lat=#{@location.coordinates[0]}&long=#{@location.coordinates[1]}&num_biz_requested=1"
			
		end
		
		def results
			@response = Net::HTTP.get_response(URI.parse(@request_url))
			@business = JSON.parse(@response.body)['businesses'][0]
			@reviews = @business['reviews']
			@reviews['total_entries'] = @business['review_count']
			@reviews
		end
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
	
	class Netflix
		attr_accessor :api_key, :shared_secret, :consumer, :request_token, :access_token
		
		def initialize
			@api_key = "srnpu8b448ca2fj5q6vkrppd"
			@shared_secret = "nuMWRS9hRQ"
			@consumer = OAuth::Consumer.new(
				      @api_key,
				      @shared_secret,
				      {
				        :site => "http://api.netflix.com",

				        :request_token_url => "https://api-user.netflix.com/oauth/request_token",
				        :access_token_url => "http://api.netflix.com/oauth/access_token",
				        :authorize_url => "https://api-user.netflix.com/oauth/login"
				      })

			@request_token = @consumer.get_request_token

		end
		
		def authorization_url	
			 @request_token.authorize_url({
			      :oauth_consumer_key => @api_key,
			      :application_name => "Nuniverse",
			      :oauth_callback => "http://localhost:3000/admin/test"
			    })
		end
		
		def set_access_token
			@access_token = @request_token.get_access_token
		end
		
		def response
			@consumer.request(
		      :get,
		      "/users/#{@access_token.response[:user_id]}",
		      @access_token,
		      {:scheme => :query_string})
		end

	end

end
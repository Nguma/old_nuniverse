module Googleizer
	attr_reader :results
	G_REFERER = 	"http://www.nuniverse.net"
	G_REST_URL = 	"http://ajax.googleapis.com/ajax/services/search"
	DEFAULT_SEARCH_MODE = "web"
	
	class Request
		attr_reader :query, :mode
		def initialize(query, params = {})
			
			@mode = self.map_mode(params[:mode].strip)
			@query = query
		end
		
		def response(params = {})
			params[:rsz] ||= "large"
			uri = "#{G_REST_URL}/#{mode}?v=1.0&q=#{query.gsub(" ", "+")}&rsz=#{params[:rsz]}"
			uri << "&sll=#{params[:sll]}" if params[:sll]
			
			Googleizer::Response.new(Net::HTTP.get_response(URI.parse(uri)),mode) rescue nil
		end
		
		def map_mode(mode)
			maps = {
				'address' => 'local',
				'local' => 'local',
				'bookmark' => 'web',
				'video' => 'video',
				'image' => 'image',
				'news' => 'news'
			}
			return maps[mode] || DEFAULT_SEARCH_MODE
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
				items << item_for(item)
			end
			items 
		end
		
		def url(item)
			return item['playUrl'] if @mode == "video"
			return CGI.unescape(item['url'])
		end
		
		
		def item_for(item)
			case @mode
			when "local"
				Location.new(
					:name => item['titleNoFormatting'],
					:full_address => "#{item['streetAddress']}, #{item['city']}, #{item['country']}",
					:latlng => "#{item['lat']},#{item['lng']}"
					)
			else
				Bookmark.new(
			:name => item['titleNoFormatting'],
	
			:description => item['content'],
			:url => url(item) 
			)
		
		end
		
		end
	end
end
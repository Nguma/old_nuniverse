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
				
				t =  Tag.new(
				:label => item['titleNoFormatting'],
				:kind => mode_to_kind,
				:service => 'google',
				:description => item['content'],
				:url => url(item) ,
				:data => "#thumbnail #{item['tbUrl'] rescue ''}"
				)
				t.replace_property("address", "#{item['streetAddress']}, #{item['city']}, #{item['country']}") if item['streetAddress']
				# item['phoneNumbers'].each do |tel|
					# t.connect(:label => tel['number'], :kind => 'telephone', :public => 1)
				# end
				t.replace_property("tel", "#{item['phoneNumbers'][0]['number']}") if item['phoneNumbers']
				t.replace_property("latlng", "#{item['lat']},#{item['lng']}") if item['lat']
				items << t
			end
			items 
		end
		
		def url(item)
			return item['playUrl'] if @mode == "video"
			return CGI.unescape(item['url'])
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
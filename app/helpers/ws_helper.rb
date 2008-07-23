module WsHelper

	def content_from_web_service(params)
		query = params[:path].tags.collect{|c| c.kind == 'user' ? "" : c.content}.join(', ')
		case params[:service]
			when "ebay"	
				return items_from_ebay(params[:path].last_tag.content)
			when "amazon"
				return items_from_amazon(params[:path].last_tag.content)
			when "daylife"
				return articles_from_daylife(:query => query.gsub(',',' '))
			when "wikipedia"
			when "google"
				return results_from_google(:query => "#{query} -amazon.com -ebay.com", :path => params[:path])
			when "videos"
				return videos_from_google(:query => "#{query}", :path => params[:path])
			when "flickr"
				return images_from_flickr(:query => query)
			when "map"
				return map_from_google(:path => params[:path])	
			else
				return "no service for #{params[:service]}"
		end
	end
	
	def items_from_ebay(query, options = {})
		response = EbayShopping::Request.new(:find_items, :query_keywords => query, :max_entries => 10).response
		return render(:partial => "/ws/ebay", :locals => {:items => response.items})
	end
	
	def items_from_amazon(query, options = {})
		response = Awsomo::Request.new().search(query,:category => options[:category] || "All")
		return render(:partial => "/ws/amazon", :locals => {:items => response})
	end
	
	def articles_from_daylife(params)
		day = Daylife::API.new('6e2eb9b4fce9bd1eff489d2c53b7ac65', '3aea4b3560e4b00e3027a7313a497f06')
		response = day.execute('search','getRelatedArticles', :query => params[:query], :limit => 10)
		return render(:partial => "/ws/daylife", :locals => {:connections => response.articles })
	end
	
	def results_from_google(params)
		GoogleAjax.referer = "http://localhost:3000"
		response = GoogleAjax::Search.web(params[:query], :rsz => "large")
		render(:partial => "/ws/google", :locals => {
			:connections => response.results,	
			:path => params[:path]
		})
	end
	
	def videos_from_google(params)
		GoogleAjax.referer = "http://localhost:3000"
		page = params[:page] || 0
		response = GoogleAjax::Search.video(params[:query], :start => page * 8, :rsz => "large")
		return render(:partial => "/ws/videos", :locals => {
			:connections => response.results,	
			:path => params[:path],
			:page => page
		})
	end
	
	def images_from_flickr(params)
		flickr = Flickr.new 'c40c269aea764bb5f53c877c3d265327'
		photos = flickr.photos(:tags => params[:query], :per_page => '10') rescue []
		return render 	:partial => "/ws/flickr", 
						:locals => {
							:photos => photos
						}

	end
	
	def map_from_google(params)
		
		gg = GoogleGeocode.new "ABQIAAAAzMUFFnT9uH0xq39J0Y4kbhTJQa0g3IQ9GZqIMmInSLzwtGDKaBR6j135zrztfTGVOm2QlWnkaidDIQ"
		markers = []
		@map = GMap.new("map_div")
		places = params[:path].tags.select {|tag| tag.has_address? }
		case places.last.kind
		when "country"
			zoom = 5
		when "city"
			zoom = 10
		else
			zoom = 15
		end
		
		#places.each do |place|
			#raise place.address.inspect
			marker = gg.locate places.last.address
			# @map.overlay_init(
			# 						GMarker.new([marker.latitude, marker.longitude],
			# 									:title => place.content, 
			# 									:info_window => "#{place.content}: #{marker.address}"
			# 					)
			# 			)				
			markers << "{'longitude':#{marker.longitude},'latitude':#{marker.latitude}, 'title':'#{places.last.content}'}"
			
		#end
		if markers.empty?
			return "No address is linked to this nuniverse."
		end
		
		
		html = "<script type='text/javascript' charset='utf-8'>
		//<![CDATA[
			
			nuniverse.options['map'] = {
				'markers':[#{markers.join(',')}],
				'zoom':#{zoom},
				'center':#{markers[0]}
			} 
		//]]>
		</script>"
		
		return render :partial => "/nuniverse/maps", :locals =>{
			:map => @map,
			:markers => markers,
			:html => html
		}
		#return @map.div(:width => "100%", :height => 450, :class => "map")
	end
	
	def details_for(params)
		case params[:service]
		when "video"
			return render :partial => "/ws/video", :locals => {:url => params[:ws_url]}
		else
			return "#TODO: This service hasn't been implemented yet"
		end
	end
end
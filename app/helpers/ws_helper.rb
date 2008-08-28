module WsHelper
		
	def update_from_freebase(tag,match)
		tag.data.replace('freebase_id', match.id)
	end
	
	def images_from_flickr(params)
		flickr = Flickr.new 'c40c269aea764bb5f53c877c3d265327'
		photos = flickr.photos(:tags => params[:query], :per_page => '10') rescue []
		return render(:partial => "/ws/flickr", 
			:locals => { :photos => photos, :path => params[:path] }
		)
	end
	
	def tweets_from_twitter(params)
		tweets = Twitter::Client.new(:login => "nuniverse", :password => "abc123").timeline_for(:public)
		return render(:partial => "/ws/twitter", 
			:locals => { :tweets => tweets, :path => params[:path] }
		)
	end
	

	
	def page_from_wikipedia(params)
		items_to_remove = [
		  "#contentSub",        #redirection notice
		  "div.messagebox",     #cleanup data
		  "#siteNotice",        #site notice
		  "#siteSub",           #"From Wikipedia..." 
		  "table.infobox",      #sidebar box
		  "#jump-to-nav",       #jump-to-nav
		  "div.editsection",    #edit blocks
		  "table.toc",          #table of contents 
		  "#catlinks"           #category links
		  ]

		doc = Hpricot open('http://en.wikipedia.org/wiki/'+params[:query].titleize.gsub(/\s|,/,'_'))
		@article = (doc/"#content").each do |content|
		  #change /wiki/ links to point to full wikipedia path
		  (content/:a).each do |link|
		    unless link.attributes['href'].nil?
		      if (link.attributes['href'][0..5] == "/wiki/")
		        link.attributes['href'].sub!('/wiki/', 'http://en.wikipedia.org/wiki/')
		      end
		    end
		  end  

		  #remove unnecessary content and edit links
		  items_to_remove.each { |x| (content/x).remove }

		  #replace links to create new entries with plain text
		  (content/"a.new").each do |link|
		    link.parent.insert_before Hpricot.make(link.attributes['title']), link
		  end.remove
		end 

		return "<div class='article'>#{@article.inner_html}</div>"
	end
	
	def map(params)
		map = GMap.new("map_div")
	  map.control_init(:large_map => true)
	  
		# case params[:location]
		# 		when "continent"
		# 			zoom = 2
		# 		when "country"
		# 			zoom = 5
		# 		when "city"
		# 			zoom = 10
		# 		else
		# 			zoom = 15
		# 		end
		# 		

		if params[:location].address
			
			markers = markers_for(Tagging.with_path_ending(params[:path]).with_address_or_geocode().paginate(:page => 1, :per_page => 10).collect{|c| c.object })
		else
			markers = markers_for([params[:location]])
		end
		
		if markers.empty?
			return false
			# return render(:partial => "/nuniverse/maps", :locals => {:no_map => true, :path => params[:path]})
		else
			 #@map.center_zoom_init([-37,-49],10)
			map.center_zoom_init([markers[0].address.lat, markers[0].address.lng],13)
			markers.each do |marker|
				map.overlay_init(GMarker.new([marker.address.lat,marker.address.lng],:title => marker.label.rstrip, :info_window => "Info! Info!"))
			end
			return map
			# html = "<script type='text/javascript' charset='utf-8'>
			# 			//<![CDATA[
			# 			
			# 				setMap({
			# 					'markers':[#{markers.join(',')}],
			# 					'zoom':#{zoom},
			# 					'center':#{markers[0]}
			# 				});
			# 			//]]>
			# 			</script>"
		end
		
		# return render(:partial => "/nuniverse/maps", :locals => {
		# 			:no_map => false,
		# 			:map => @map,
		# 			:markers => markers,
		# 			:html => html,
		# 			:path => params[:path]
		# 		})
	end
	
	def markers_for(places)
		# gg = GoogleGeocode.new "ABQIAAAAzMUFFnT9uH0xq39J0Y4kbhTJQa0g3IQ9GZqIMmInSLzwtGDKaBR6j135zrztfTGVOm2QlWnkaidDIQ"
	
		markers = []
		places.each do |place|
			if place.has_coordinates?
					markers << place	
			elsif place.has_address?
					place.find_coordinates
					markers << place
			end
		end
		return markers
		# return markers.collect {|marker| 
		# 			"{'longitude':'#{marker.address.lng}','latitude':'#{marker.address.lat}', 'title':'#{h marker.label.rstrip}<br/>#{}'}"
		# 		}
	end
	
	def details_for(params)
		case params[:service]
		when "ebay"
			response = EbayShopping::Request.new(:get_single_item, :itemID => params[:id]).response
			return render(:partial => "/ws/ebay_item", :locals => {:item => response.item, :response => response,  :path => params[:path]})
		when "amazon"
			response = Awsomo::Request.new(:operation => "ItemLookup", :item_id => params[:id]).response		
			return render(:partial => "/ws/amazon_item", :locals => {:item => response.item,  :path => params[:path]})			
		when "video"
			return render(:partial => "/ws/video", :locals => {:url => params[:id], :flashvars => params[:flashvars] || "", :path => params[:path]})
		else
			return "#TODO: The service for #{params[:service]} hasn't been implemented yet"
		end
	end
	
	def sanatized_query_from_path(path)
		return path.tags.collect {|t| t.kind == 'user' ? "" : "#{t.kind == 'channel' ? '' : t.kind} #{t.label}"}.join(' ')
	end
	

end
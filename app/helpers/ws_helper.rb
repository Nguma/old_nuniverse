module WsHelper

	def content_from_web_service(params)
		query = params[:path].tags.collect{|c| c.kind == 'user' ? "" : c.content}.join(', ')
		case params[:service]
			when "ebay"	
				return items_from_ebay(params[:path].last_tag.content, :path => params[:path])
			when "amazon"
				return items_from_amazon(:query => params[:path].last_tag.content, :path => params[:path])
			when "daylife"
				return articles_from_daylife(:query => query.gsub(',',' '), :path => params[:path])
			when "wikipedia"
				return page_from_wikipedia(:query => params[:path].last_tag.content)
			when "google"
				return results_from_google(:path => params[:path])
			when "local"
				return results_from_google_local(:path => params[:path])
			when "videos"
				return videos_from_google(:path => params[:path])
			when "flickr"
				return images_from_flickr(:query => sanatized_query_from_path(params[:path]), :path => params[:path])
			when "twitter"
				return tweets_from_twitter(:query => sanatized_query_from_path(params[:path]), :path => params[:path])
			when "map"
				return map_from_google(:path => params[:path])	
			else
				return "no service for #{params[:service]}"
		end
	end
	
	def items_from_ebay(query, options = {})
		response = EbayShopping::Request.new(:find_items, :query_keywords => query, :max_entries => 10).response
		return render(:partial => "/ws/ebay", :locals => {:items => response.items, :path => params[:path]})
	end
	
	def items_from_amazon(params)
		response = Awsomo::Request.new(:query => params[:query], :category => params[:category] || "All").response
		return render(:partial => "/ws/amazon", :locals => {:items => response.items, :path => params[:path]})
	end
	
	def articles_from_daylife(params)
		day = Daylife::API.new('6e2eb9b4fce9bd1eff489d2c53b7ac65', '3aea4b3560e4b00e3027a7313a497f06')
		response = day.execute('search','getRelatedArticles', :query => params[:query], :limit => 10)
		return render(:partial => "/ws/daylife", :locals => {:connections => response.articles, :path => params[:path]})
	end
	
	def results_from_google(params)
		GoogleAjax.referer = "http://localhost:3000"
		
		response = GoogleAjax::Search.web("#{sanatized_query_from_path(params[:path])} -amazon.com -ebay.com -youtube.com", :rsz => "large")
		render(:partial => "/ws/google", :locals => {
			:connections => response.results,	
			:path => params[:path]
		})
	end
	
	def results_from_google_local(params)
		GoogleAjax.referer = "http://localhost:3000"
		response = GoogleAjax::Search.local(params[:path].last_tag.content,70,70, :rsz => "large")
		render(:partial => "/ws/local", :locals => {
			:locations => response.results,	
			:path => params[:path]
		})
	end
	
	def videos_from_google(params)
		GoogleAjax.referer = "http://localhost:3000"
		page = params[:page] || 0
		
		response = GoogleAjax::Search.video(sanatized_query_from_path(params[:path]), :start => page * 8, :rsz => "large") rescue nil
	 	return "No videos :(" if response.nil?
		return render(:partial => "/ws/videos", :locals => {
			:connections => response.results,	
			:path => params[:path],
			:page => page
		})
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
	
	def map_from_google(params)
		@map = GMap.new("map_div")
		
		case params[:path].tags.last.kind
		when "continent"
			zoom = 2
		when "country"
			zoom = 5
		when "city"
			zoom = 10
		else
			zoom = 15
		end
		
		if params[:path].tags.last.kind == "topic"
			markers = markers_for(Tagging.with_path_ending(params[:path]).with_address_or_geocode().paginate(:page => 1, :per_page => 10).collect{|c| c.object })
		else
			markers = markers_for([params[:path].tags.last])
		end
		
		if markers.empty?
			return "Sorry, no map for #{params[:path].tags.last.address}"
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
		
		return render(:partial => "/nuniverse/maps", :locals => {
			:map => @map,
			:markers => markers,
			:html => html
		})
	end
	
	def markers_for(places)
		gg = GoogleGeocode.new "ABQIAAAAzMUFFnT9uH0xq39J0Y4kbhTJQa0g3IQ9GZqIMmInSLzwtGDKaBR6j135zrztfTGVOm2QlWnkaidDIQ"
		markers = []
		places.each do |place|
			if place.has_coordinates?
				markers << place
				
			elsif place.has_address?
				ggp = gg.locate place.address rescue nil
				unless ggp.nil?
					place.data =  "#{place.data} #latlng #{ggp.latitude},#{ggp.longitude}"
					place.save
					markers << place
				end
				
			end
		end
		return markers.collect {|marker| "{'longitude':'#{marker.longitude}','latitude':'#{marker.latitude}', 'title':'#{h marker.content.rstrip}'}"}
	end
	
	def details_for(params)
		case params[:service]
		when "ebay"
			response = EbayShopping::Request.new(:get_single_item, :itemID => params[:id]).response
			return render(:partial => "/ws/ebay_item", :locals => {:item => response.item, :response => response})
		when "amazon"
			response = Awsomo::Request.new(:operation => "ItemLookup", :item_id => params[:id]).response		
			return render(:partial => "/ws/amazon_item", :locals => {:item => response.item})			
		when "video"
			return render(:partial => "/ws/video", :locals => {:url => params[:id], :flashvars => params[:flashvars] || ""})
		else
			return "#TODO: The service for #{params[:service]} hasn't been implemented yet"
		end
	end
	
	def sanatized_query_from_path(path)
		return path.tags.collect {|t| t.kind == 'user' ? "" : "#{t.kind == 'topic' ? '' : t.kind} #{t.content}"}.join(' ')
	end
end
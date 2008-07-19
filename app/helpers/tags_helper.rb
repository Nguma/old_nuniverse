module TagsHelper

	
	def ebay(params)
		return render :partial => "/nuniverse/ebay", :locals =>
		{
			:connections => EbayShopping::Request.new(:find_items, {:query_keywords => params[:query], :max_entries => 8}).response.items
		}
		
	end
	
	def amazon(params)
		return render :partial => "/nuniverse/amazon", :locals =>
		{
			:connections => Awsomo::Request.new().search(params[:query], :category => params[:category] ||= "All")
		}
	end
	
	
	def daylife(params)
		day = Daylife::API.new('6e2eb9b4fce9bd1eff489d2c53b7ac65', '3aea4b3560e4b00e3027a7313a497f06')
		return render :partial => "/nuniverse/daylife", :locals =>
		{
			:connections => day.execute('search','getRelatedArticles', :query => params[:query], :limit => 5).articles
		}
	end
	
	def google(params)
		GoogleAjax.referer = "http://localhost:3000"
		return render :partial => "/nuniverse/google", :locals =>
		{
			:connections => GoogleAjax::Search.web(params[:query]).results,
			:path => params[:path]
		}
	end
	
	def flickr(params)
		flickr = Flickr.new 'c40c269aea764bb5f53c877c3d265327'
		photos = flickr.photos(:tags => params[:query], :per_page => '10') rescue []
		return render 	:partial => "/nuniverse/flickr", 
						:locals => {
							:photos => photos
						}

	end
	
	def geolocate(params)
		map = GMap.new("map_div")
		map.control_init(:large_map => true, :map_type => true, :local_search => true)
		gg = GoogleGeocode.new "ABQIAAAAzMUFFnT9uH0xq39J0Y4kbhTJQa0g3IQ9GZqIMmInSLzwtGDKaBR6j135zrztfTGVOm2QlWnkaidDIQ"
		markers = []
		places = params[:path].tags.select {|tag| tag.has_address? } || []
		places.each do |place|
			raise tag.address.inspect
			marker = gg.locate tag.address
			map.overlay_init(
				GMarker.new([marker.latitude, marker.longitude],
					:title => place.content, 
					:info_window => "#{place.content}: #{marker.address}"
				)
			)				
			markers << marker
		end
		
		#path.tags.select {|tag| tag.kind == "location"}.reverse.map {|c| c.description }
		#loc = gg.locate query
		# unless markers.empty?
		# 	@map.center_zoom_init([markers[0].latitude, markers[0].longitude],15)
		# else
		# 	@map.center_zoom_init("new York City",5)
		# end
		#  	
		map.center_zoom_init("New York City",5)
		return map.div(:width => "100%", :height => 450)
	end
	
	def h3_for(path)
		
		sentence = ""
		path.tags.each do |tag|
			
			case tag.kind
		    when "location"
		      sentence << "you're at #{tag.content} "
		    when "person"
		       sentence << "you are meeting with #{tag.content} "
				when "quest"
					sentence << "your quest is to #{tag.content} "
				when "item"
					sentence << "you have a #{tag.content} "
				when "topic"
					sentence << "you talk about #{tag.content}"
		    else
		       "Are you ready for this adventure?"
			end
		end
		sentence
		
	end
	
	def header_for(params, &block)
		params[:body] = capture(&block)
		concat(
			render(
				:partial => "/nuniverse/header", 
				:locals => params
			), block.binding
		)		
	end
	
	def nuniverse_for(params)
		# params[:left] = render( 
		#         			:partial => "/nuniverse/#{params[:tag].kind}_left", 
		#         			:locals => {:tag => params[:tag], :path => @path}
		#       			) 

		params[:body] = render(
	            :partial => "/nuniverse/#{params[:tag].kind}", 
	            :locals => {:tag => params[:tag], :path => @path}
	          ) 

	     render(
	        :partial => '/nuniverse/instance',
	        :locals => params
	      )			
	end
	
	
	def new_tag_form(params)
		params[:title] ||= "Add a new #{params[:kind]}"
		render(
			:partial => "/tags/new", 
			:locals => params
			)
	end
	
	
	def list_for(params, &block)
		params[:path]     ||= TaggingPath.new
		params[:header]    = capture(&block)
		params[:reverse]  ||= false
    
		params[:connections] = Tagging.with_path(params[:path]).by_latest
		
		if params[:reverse]
		  params[:connections] = params[:connections].with_subject_kinds(params[:kind])
	  else
	    params[:connections] = params[:connections].with_object_kinds(params[:kind])
    end
			
		concat(
			render(
				:partial => "/nuniverse/list", 
				:locals => params
			), block.binding
		)
	end
	

end

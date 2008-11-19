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
	
	def amazon_box(params)
		items = Finder::Search.find(:query => params[:source].label, :service => 'amazon')
		render :partial => "/nuniverse/amazon_box", :locals => {:source => params[:source], :items => items}
	end
	

	
	
	def map(tag, params = {})
		map = GMap.new("map_#{tag.id}","map_#{tag.id}")
	  map.control_init(:small_zoom => true)
		markers = markers_for(tag)
		
		return false if markers.empty?
		map.center_zoom_init([markers[0].address.lat, markers[0].address.lng],12)
		markers.each do |marker|
			map.overlay_init(GMarker.new([marker.address.lat,marker.address.lng],:title => marker.label.rstrip, :info_window => "<b>#{marker.label.rstrip}</b> <p style='font-size:11px'>#{marker.property('address')}</p>"))
		end
		return map
	end
	
	def markers_for(places)	
		markers = []
		places.to_a.each do |place|
			if place.has_coordinates?
					markers << place	
			elsif place.has_address?
					place.find_coordinates
					markers << place
			end
		end
		return markers
	end
	
	def google_localize(params)
		if params[:source].is_a?(Tagging) && params[:source].subject.has_address?
			sll = params[:source].subject.coordinates.join(',')
			query = "#{params[:source].label} #{params[:source].kind}"
		else
			sll = Graticule.service(:host_ip).new.locate(request.remote_ip).coordinates.join(',') rescue "40.746497,-74.009447"	
			query = params[:source]
		end
		Googleizer::Request.new(query, :mode => "local").response(:sll => sll, :rsz => "small").results
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
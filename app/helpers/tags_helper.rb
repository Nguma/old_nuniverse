module TagsHelper


	def tag_content
		params[:kind] ||= @kind
		if service_is_nuniverse?
			lists_for(@tag)
		else
			results = []
			service_items.each_with_index do |result,i|
				results << "#{render :partial => "/taggings/#{@service}", :locals => {:result => result, :tag => @tag}}"
			end
			results
		
		end
	end
	
	
	def service_items
		query = "+#{@source.label}  #{tag_info(@source)}"
		case @service
		when "google"	
			Googleizer::Request.new(query , :mode => "web").response.results
		when "amazon"
			query = "#{@source.label}"
			Finder::Search.find(:query => query, :kind => @kind,:service => 'amazon')
		when "youtube"
			Googleizer::Request.new(query , :mode => "video").response.results
		else
		end
	end
	
	def tag_info(tag, params = {})
		params[:kind] ||= @kind
		case params[:kind].singularize
		when "film"
			return tag.property("release_date")
		when "location","restaurant","museum"
			return "#{tag.address.full_address} - #{tag.property("tel")}"
		when "bookmark"
			return tag.url.scan(/http.{1,3}\/\/([^\/]*).*/)[0]
		when "album","artwork","painting","sculpture"
			# raise tag.connections.inspect
			info = [tag.connections(:kind => 'artist|painter|musician|sculptor', :user => current_user).first] rescue []
			info << tag.connections(:kind => 'creation date', :user => current_user).first
			info.collect {|c| c.nil? ?  "" : c.title}.join(' - ')
		when "person"
			return connections(:subject => tag, :kind => 'occupation|profession').first rescue []
		when "product"
			return "#{tag.property('price')} on #{tag.service.capitalize}"
		else
			return ""
		end
	end
	
	def tag_links(tag, params = {})
		params[:kind] ||= @kind
		case params[:kind].singularize
		when 'film'
			[link_to("Rent it on Netflix","#"),link_to("Buy it on Amazon",tag_url(tag, :service => 'amazon', :kind => params[:kind]))]
		when 'location'
		when 'restaurant','bar','club'
			[link_to("Reviews from yelp","#")]
		when 'bookmark'
			[]
		when 'album'
			[]
		else
			[]
		end
	end
end
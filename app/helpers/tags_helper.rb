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
			Finder::Search.find(:query => query, :service => 'amazon')
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
			return tag.address.full_address
		when "bookmark"
			return tag.url.scan(/http.{1,3}\/\/([^\/]*).*/)[0]
		when "album","artwork","painting","sculpture"
			# raise tag.connections.inspect
			info = ["#{tag.connections(:kind => 'artist', :user => current_user).first.label} "] rescue []
			info << tag.property("release_date")
			info.join(' - ')
		else
			return tag.description
		end
			
	end
end
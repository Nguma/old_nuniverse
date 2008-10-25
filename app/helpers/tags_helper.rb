module TagsHelper


	def tag_content
		params[:kind] ||= @list.label.singularize

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
		case @service
		when "google"	
			Googleizer::Request.new(@list.title , :mode => "web").response.results
		when "amazon"
			Finder::Search.find(:query => @list.title, :service => 'amazon')
		when "youtube"
			Googleizer::Request.new(@list.title , :mode => "video").response.results
		else
		end
	end
end
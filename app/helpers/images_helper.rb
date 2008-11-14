module ImagesHelper
	
	# image for the corresponding source
	def avatar_for(source)
		source = source.is_a?(Tagging) ? source.object : source
		return nil if source.avatar.blank?
		return image_tag(source.avatar, :alt => source.avatar, :class => "avatar") rescue nil
	end

	# thumbail image for the corresponding source
	def thumbnail_tag(source, params = {})
		source = source.is_a?(Tagging) ? source.object : source
		params[:kind] ||= @kind.nil? ? source.kind : @kind
		unless source.thumbnail.nil?
			img = source.thumbnail
		else
			img = "/images/icons/#{params[:kind].singularize}.png"
		end
		return image_tag(img, :alt => "", :class => params[:class] || "thumbnail")
	
	end
	
	
	def images_for(collection, params = {})
		params[:source] ||= nil
		collection.collect {|c| 
			render :partial => "/images/box", :locals => {:item => c, :source => params[:source]}
		 }
	end
	
end

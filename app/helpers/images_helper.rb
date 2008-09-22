module ImagesHelper
	
	def avatar_for(source)
		source = source.is_a?(Tagging) ? source.object : source
		return nil if source.avatar.blank?
		return image_tag(source.avatar, :alt => source.avatar, :class => "avatar") rescue nil
	end
	
	def icon_for(tag)
		return image_tag(tag.icon, :alt => tag.kind, :class => "icon") rescue ""
	end
	
	def thumbnail_tag(tag)
		return image_tag(tag.thumbnail, :alt => "", :class => "thumbnail") 
	end
	
	
	def images_for(collection, params = {})
		params[:source] ||= nil
		collection.collect {|c| 
			render :partial => "/images/box", :locals => {:item => c, :source => params[:source]}
		 }
	end
	
end

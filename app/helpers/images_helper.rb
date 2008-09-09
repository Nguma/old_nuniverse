module ImagesHelper
	
	def avatar_for(source)
		source = source.is_a?(Tagging) ? source.object : source
		return nil if source.avatar.blank?
		return image_tag(source.avatar, :alt => source.kind, :class => "avatar") rescue nil
	end
	
	def icon_for(tag)
		return image_tag(tag.icon, :alt => tag.kind, :class => "icon") rescue ""
	end
	
	def thumbnail_tag(tag)
		return nil if tag.thumbnail.blank?
		return image_tag(tag.thumbnail, :alt => tag.kind, :class => "thumbnail") rescue nil
	end
	
	
	def images_for(collection)
		collection.collect {|c| render :partial => "/images/box", :locals => {:source => c}}
	end
	
end

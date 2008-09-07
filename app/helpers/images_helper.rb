module ImagesHelper
	
	def avatar_for(tag)
		return nil if tag.avatar.blank?
		return image_tag(tag.avatar, :alt => tag.kind, :class => "avatar") rescue nil
	end
	
	def icon_for(tag)
		return image_tag(tag.icon, :alt => tag.kind, :class => "icon") rescue ""
	end
	
	def thumbnail_tag(tag)
		return nil if tag.thumbnail.blank?
		return image_tag(tag.thumbnail, :alt => tag.kind, :class => "thumbnail") rescue nil
	end
	
end

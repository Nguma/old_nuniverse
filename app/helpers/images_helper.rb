module ImagesHelper
	
	def avatar_for(tag)
		if !tag.avatar.blank?
			return image_tag(tag.avatar, :alt => tag.kind, :class => "avatar") rescue nil
		else
			return nil
		end
	end
	
	def icon_for(tag)
		return image_tag(tag.thumbnail, :alt => tag.kind, :class => "icon") rescue ""
	end
	
end

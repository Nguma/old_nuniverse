module AvatarsHelper
	
	def avatar_for(tag)
		if !tag.image.blank?
			return image_tag(tag.image, :alt => tag.kind, :class => "avatar") rescue nil
		else
			return nil
		end
	end
	
	def icon_for(tag)
		return image_tag(tag.thumbnail, :alt => tag.kind, :class => "avatar") rescue ""
	end
	
end

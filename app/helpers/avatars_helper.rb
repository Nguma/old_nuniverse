module AvatarsHelper
	
	def avatar_for(tag)
		return image_tag(tag.thumbnail, :alt => tag.kind, :class => "avatar") rescue ""
	end
	
end

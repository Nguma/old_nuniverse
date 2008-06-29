# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
	def head_for(view)
		return render(:partial => "/#{view}/head") rescue nil
	end
	
	
	def avatar_for(tag)
		return "" if tag.avatar.nil?
		return link_to(image_tag(tag.avatar.public_filename(:small), :alt => tag.content, :style =>"width:20px"), tag, :class => 'avatar')
	end
end

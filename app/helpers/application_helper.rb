# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
	def head_for(view)
		return render(:partial => "/#{view}/head") rescue nil
	end
	
	
	def avatar_for(tag)
		return image_tag(tag.thumbnail, :alt => tag.kind, :class => "avatar") 
	end
	
	def link_to_nuniverse(tag, options = {})		
		return link_to("You",	"/my_nuniverse", :class => options[:class]) if logged_in? && current_user.tag == tag 
		label = tag.content.capitalize
		label = "#{label[0,options[:max]]}..." if options[:max] && label.length > options[:max]
		options[:path] ||= []
	
		case tag.kind
		when "bookmark"
			return link_to(label, tag.url, :target => "_blank")
		else
			return link_to(label,	"/nuniverse_of/#{options[:path]}#{tag.id}", :class => "main inner")
		end
	end
	
	def link_to_tagging(tagging, options = {})
		if logged_in? && current_user.tag == tagging.last_tag
			return link_to("You",	"/my_nuniverse", :class => options[:class])
		end
		
		label = tagging.last_tag.content
		if max = options.delete(:max)
			label = "#{label[0..max]}..." if label.length > max
		end
		
		return link_to(label, "/nuniverse_of/#{tagging.to_s}", options)
	end

	def menu(params = {}, &block)
		params[:body] = capture(&block)
		params[:classes] ||= ""
		params[:name] ||= ""
		concat(
		render(
			:partial => "/nuniverse/menu",
			:locals => params
		), block.binding)
	end
	
	def menu_item(params)
		params[:classes] ||= ""
		if params[:selected] && params[:label] == params[:selected].capitalize
			params[:classes] << " selected"
		end
		render(
			:partial => "/nuniverse/menu_item",
			:locals => params
		)
	end
end

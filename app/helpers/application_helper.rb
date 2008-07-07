# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
	def head_for(view)
		return render(:partial => "/#{view}/head") rescue nil
	end
	
	
	def avatar_for(tag)
		return "" if tag.avatar.nil?
		return link_to(image_tag(tag.avatar.public_filename(:large), :alt => tag.content), tag, :class => 'avatar')
	end
	
	def path_for(path, options = {})
		
		crumbs = Tagging.crumbs(path)
		
		# Setting a default partial for rendering the path
		partial = options[:partial] || "/taggings/path"
		render(
				:partial => partial,
				:locals => {:tags => tags, :path => crumbs})
		
	end
	
	
	def link_to_nuniverse(tag, options = {})
		
		return link_to("You",	"/my_nuniverse", :class => options[:class]) if logged_in? && current_user.tag == tag 
		label = tag.content.capitalize
		label = "#{label[0,options[:max]]}..." if options[:max] && label.length > options[:max]
		# options[:path] ||= []
		# options[:path] << tag
	
		return link_to(label,	"/nuniverse_of/#{options[:path].to_s.gsub(/^_/, '')}#{tag.id}", :class =>options[:class])
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
	
	def header_for(tag)
		if logged_in? && current_user.tag == tag
			label = "Your nuniverse"
			superlabel = "Welcome to"
			sublabel = ""
		else
			label = tag.content.capitalize
			superlabel = "You are visiting the nuniverse of"
			sublabel = ""
		end
		render(
			:partial => "/tags/header",
			:locals => {
				:label => label,
				:tag => tag
			}
		)
	end
	
	def default_content_for(name, &block)
	  name = name.kind_of?(Symbol) ? ":#{name}" : name
	  out = eval("yield #{name}", block.binding)
	  concat(out || capture(&block), block.binding)
	end


end

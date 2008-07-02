# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
	def head_for(view)
		return render(:partial => "/#{view}/head") rescue nil
	end
	
	
	def avatar_for(tag)
		return "" if tag.avatar.nil?
		return link_to(image_tag(tag.avatar.public_filename(:small), :alt => tag.content), tag, :class => 'avatar')
	end
	
	def path_for(path, options = {})
		
		crumbs = Tagging.crumbs(path)
		
		# Setting a default partial for rendering the path
		partial = options[:partial] || "/taggings/path"
		render(
				:partial => partial,
				:locals => {:tags => tags, :path => crumbs})
		
	end
	
	def nuniverse_of(params, &block)
		params.merge!(:body => capture(&block))
		params[:sidebar_left] ||= render :partial => "/tags/default_filters", :locals => {:path => params[:path]}
		params[:sidebar_right] ||= ""
    concat(
      render(
        :partial => '/tags/nuniverse',
        :locals => params
      ), block.binding
    )
	end
	
	def link_to_nuniverse(tag, options = {})
		
		return link_to("You",	"/my_nuniverse", :class => options[:class]) if logged_in? && current_user.tag == tag 
		label = tag.content.capitalize
		label = "#{label[0,options[:max]]}..." if options[:max] && label.length > options[:max]
		options[:path] ||= []
		options[:path] << tag
	
		return link_to(label,	"/nuniverse_of/#{options[:path].collect {|c| c.id}.join('_')}", :class =>options[:class])
	end
	
	def header_for(tag)
		if logged_in? && current_user.tag == tag
			@label = "Your nuniverse"
		else
			@label = tag.content.capitalize
		end
		render(
			:partial => "/tags/header",
			:locals => {
				:label => @label,
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

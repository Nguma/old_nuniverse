# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
	def head_for(view)
		return render(:partial => "/#{view}/head") rescue nil
	end
	
	
	def avatar_for(tag)
		return link_to(image_tag("/images/icons/#{tag.kind}.png", :alt => tag.kind), "/nuniverse_of/#{tag.id}", :class=>'avatar', :title => "#{tag.kind}: #{tag.content}") if tag.avatar.nil?
		return link_to(image_tag(tag.avatar.public_filename(:large), :alt => tag.content), "/nuniverse_of/#{tag.id}", :class => 'avatar', :title => "#{tag.kind}: #{tag.content}")
	end
	
	# def path_for(path, options = {})
	# 		
	# 		crumbs = Tagging.crumbs(path)
	# 		
	# 		# Setting a default partial for rendering the path
	# 		partial = options[:partial] || "/taggings/path"
	# 		render(
	# 				:partial => partial,
	# 				:locals => {:tags => tags, :path => crumbs})
	# 		
	# 	end
	
	def connections_for(context, options = {})
		
		@perspective = options[:perspective] || "everyone"
		options[:page] ||= 1
		@filter = options[:filter] || nil
		if context.is_a?(String)
			query = context
		elsif context.is_a?(TaggingPath)
			query = context.last_tag.content
		else
			return Error
		end
		
		case @perspective
			when "ebay"				
				render :partial => "/nuniverse/ebay", :locals => {:query => query}
			when "amazon"
				render :partial => "/nuniverse/amazon", :locals => {:query => query}
			when "daylife"
				render :partial => "/nuniverse/daylife", :locals => {:query => query}
			when "google"
				render :partial => "/nuniverse/google", :locals => {:query => query}
			when "maps"
				render :partial => "/nuniverse/maps", :locals => {:query => context.last_tag}
			when "me"
				@connections = Tagging.with_user(current_user).with_path_ending(context).with_object_kinds(@filter).groupped.by_latest.paginate(
					:page => options[:page],
					:per_page => 8
				)
				render :partial => "/nuniverse/connections", :locals => {:connections => @connections, :path => context}
			else
				@connections = Tagging.with_path_ending(context).with_object_kinds(@filter).groupped.by_latest.paginate(
					:page => options[:page], 
					:per_page => 8
				)
				render :partial => "/nuniverse/connections", :locals => {:connections => @connections, :path => context}
		end
	end
	
	
	def link_to_nuniverse(tag, options = {})
		
		return link_to("You",	"/my_nuniverse", :class => options[:class]) if logged_in? && current_user.tag == tag 
		label = tag.content.capitalize
		label = "#{label[0,options[:max]]}..." if options[:max] && label.length > options[:max]
		# options[:path] ||= []
		# options[:path] << tag
	
		return link_to(label,	"/nuniverse_of/#{tag.id}", :class =>options[:class])
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
		concat(
		render(
			:partial => "/nuniverse/menu",
			:locals => params
		), block.binding)
	end
	
	def menu_item(name, params = {}, &block)
		params[:body] = capture(&block)
		params[:classes] ||= ""
		if params[:selected] && name == params[:selected]
			params[:classes] << " selected"
		end
		concat(
		render(
			:partial => "/nuniverse/menu_item",
			:locals => params
		), block.binding)
	end

end

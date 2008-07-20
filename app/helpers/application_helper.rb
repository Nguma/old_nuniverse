# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
	def head_for(view)
		return render(:partial => "/#{view}/head") rescue nil
	end
	
	
	def avatar_for(tag)
		return link_to(image_tag("/images/icons/#{tag.kind}.png", :alt => tag.kind), "/nuniverse_of/#{tag.id}", :class=>'avatar', :title => "#{tag.kind}: #{tag.content}") if tag.avatar.nil?
		return link_to(image_tag(tag.avatar.public_filename(:large), :alt => tag.content), "/nuniverse_of/#{tag.id}", :class => 'avatar', :title => "#{tag.kind}: #{tag.content}")
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
	
	def page_for(params ={}, &block)
		raise "No tag is specified for page" if params[:tag].nil?
		params[:content] = capture(&block)
		params[:path] ||= params[:tag].id
		params[:classes] ||= ""
		concat(
			render(
				:partial => "/nuniverse/page",
				:locals => params
		), block.binding)
	end
	
	def content_for_page(params ={})
		raise "No tag is specified for content block" if params[:tag].nil?
		params[:perspective] ||= "me"
		params[:filter] ||= nil
		params[:classes] ||= ""
		params[:page] ||= 1
		params[:path] ||= params[:tag].id
		
		if params[:tag].kind == "video"
			params[:connections] = render :partial => "/nuniverse/youtube",
			:locals => {:url => params[:tag].url}
		else
		
		query = params[:path].tags.collect{|c| c.kind == 'user' ? "" : c.content}.join(', ') 
		case @perspective
			when "ebay"	
				params[:connections] = ebay(:query => params[:path].last_tag.content.to_s)			
			when "amazon"
				params[:connections] = amazon(:query => params[:path].last_tag.content.to_s)	
			when "daylife"
				params[:connections] = daylife(:query => query.gsub(',',' '))	
			when "google"
				params[:connections] = google(:query => "#{query} -amazon.com -ebay.com", :path => params[:path])
			when "flickr"
				params[:connections] = flickr(:query => query)
			when "map"
				params[:connections] = geolocate(:path => params[:path])
			when "you"
				params[:connections] = render :partial => "/nuniverse/connections", :locals => {
					:connections => Tagging.with_user(current_user).with_path_ending(params[:path]).with_object_kinds(params[:filter]).groupped.by_latest.paginate(
						:page => params[:page], 
						:per_page => 20
						),
					:path => params[:path]
				}
			else
				
				params[:connections] = render :partial => "/nuniverse/connections", :locals => {
					:connections => Tagging.with_path_ending(params[:path]).with_object_kinds(params[:filter]).groupped.by_latest.paginate(
						:page => params[:page], 
						:per_page => 20
						),
					:path => params[:path]
				}
		end
	end
		return render(
			:partial => "/nuniverse/content",
			:locals => params
		)
	end

end

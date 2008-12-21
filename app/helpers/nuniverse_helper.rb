module NuniverseHelper

	# Columnize
	# Queries for connections of given kind, and renders each one of them in a table,
	# of a given column size.
	# parameters:
	# :size = number of columns
	# :kind = specific kind to be passed to query
	# :mode = if set to direct, will require current_user to be subject
	# :source = source to query from
	# :dom_classes = Array of classes to assign to each column. Eg: ["","big_column","small_column"]
	def columnize(boxes, params = {})
		html = ""
		params[:size] ||= column_size
		params[:dom_classes] ||= []
		cols = Array.new(params[:size])
		# boxes = [ad_box,boxes]
		boxes.flatten.each_with_index do |box, i|
			(cols[i%params[:size]] ||= "") << box
		end
		
		cols.each_with_index do |col, i|
			col_html = render :partial => "/nuniverse/column", :locals => {
				:dom_class => params[:dom_classes][i] || "",
				:dom_id => params[:dom_id] || "column_#{i}",
				:width => "#{(100.00/(params[:size]))}%",
				:col_content => cols[i]
			}
			html << col_html
		end
		
		html
	end
	
	def column_size
		case @display
		
		when "card"
			1
		when "image"
			5
		when "list"
			1
		else
			1
		end
	end
		
	def command(params)
		params[:command]  ||= "Add to #{params[:kind]}"
		params[:description] ||= params[:label]
		link_to(params[:label],params[:command],:class => "command", :title => params[:description])
	end
	
	def content_for_item(item, params = {})
		params[:kind] ||= @list.label.singularize

		if service_is_nuniverse?
			lists_for(item)
		else
			results = []
			@items.each_with_index do |result,i|
				results << "#{render :partial => "/taggings/#{@service}", :locals => {:result => result, :tagging => item}}"
			end
			results
		
		end
	end
	
	def description_box(params = {})
		params[:source] ||= @source
		render :partial => "description_box", :locals => {:source => params[:source] }
	end
	
	def drop_command(params) 
		
		link_to("<span class='pls'>+</span> #{params[:category]}", "/command/add/#{params[:category]}?tagging=#{params[:tagging].id}", :class => params[:class] || nil)
	end
	
	def input(params)
		params[:source] ||= @source
		render :partial => "/nuniverse/input" , :locals => {
		  :source => params[:source]
		 }
	end
	
	def link_to_object(object, params = {})
		
		case object.kind
		when 'item'
			url = h "/ws/show?service=#{object.service}&item=#{CGI::escape(object.link.rstrip)}"
		when "video"
			url = h "/ws/show?service=video&item=#{CGI::escape(object.url.rstrip)}&flashvars=#{CGI::escape(object.property('flashvars'))}"
		when 'bookmark'
			url = CGI::unescape(object.url)
			dom_class = ""
		else
			url = "/section_of/#{params[:path]}"
		end
		
		link_to(object.label.capitalize, url, :class => dom_class || "inner")
	end
	
	def nuniverse(params = {}, &block)
		params[:content] = capture(&block)
		params[:selected] ||= ""
		concat(
			render(
				:partial => "/nuniverse/instance",
				:locals => params
		))		
	end
	
	def render_hat(params)
		if params[:subject]
			params[:image] ||= avatar_for(params[:subject])
			params[:label] ||= params[:subject].label
			params[:kind] ||= params[:subject].kind
			params[:description] ||= params[:subject].description
			params[:options] ||= link_to("edit", "/tags/edit/#{params[:subject].id}", :class => "edit")
		end
		return render(:partial => "/nuniverse/hat", :locals => params, :section => params[:section])
	end
	
	def spinner(params ={})
		params[:message] ||= ""

		render :partial => "/nuniverse/spinner", :locals => params
	end
	
	# Service_is_nuniverse?
	# Returns true if selecte dservice / perspective is prioritary to nuniverse.
	def service_is_nuniverse?(params = {})
		if params[:service]
			@user = User.find(:first, :conditions => ['login = ?', params[:service]] )
		end
		return false if !@user.nil? && @user.role == "service"
		return true
	end
	
	def title(params ={})
		params[:source] ||= @source
		return if params[:source].nil?
		render(:partial => "title_box", :locals => params) rescue render(:partial => "/nuniverse/title_box", :locals => params)
	end
	
	def empty_slot(params ={})

		image_tag("/images/backgrounds/empty_perspective.png", :class => "empty_slot", :alt => "Drop a perspective here", :style => "position:relative;")
	end
	
	def urize(params)
		params[:mode] ||= @mode
		params[:id] ||= @source.id
		case @source.class.to_s
		when "List"
			listing_url(params)
		when "User"
			user_url(params)
		else
			tag_url(params)
		end
	end
	
	def search_box
		render :partial => "/nuniverse/search_box"
	end
	
	def save_button(item, tagging)
		render :partial => "/taggings/bookmark", :locals => {:item => item, :tagging => tagging}
	end
	
	def property(property)
		unless !property || property.blank?
			render :partial => "/taggings/property", :locals => {:property => property}
		end
	end

	def box(params)
		params[:dom_class] ||= ""
		params[:title] ||= params[:source].title
		params[:dom_id] ||= params[:title].pluralize.gsub(" ", "_")
		render :partial => "/taggings/box", :locals => params
	end
	
	def tag_box(params) 
		params[:source] ||= current_user.tag
		
		render :partial => "/tags/box", :locals => {
			:items => params[:source].tags,
			:title => "Tags"
		}
	end

	
	def content_for_service(params)
		params[:service] ||= @service
		if !service_is_nuniverse?
			render :partial => "/taggings/#{service}", :locals => {:source => params[:source]}
		else
			render :partial => "/taggings/default_content", :locals => {:source => params[:source]}
		end
	end
	
	def save_button(item, params = {})
		params[:item] = item
		render :partial => "/taggings/manage", :locals => params
	end
	
	
	def cancel_button(params ={})
		params[:style] = "position:relative;clear:both;left:0;margin:10px 0 0 0;#{params[:style]}"
		link_to image_tag("/images/icons/cancel_btn.png"), "#", :title => "Cancel", :class =>"close_btn", :style => params[:style]
	end
		
	
	def menu_window(params, &block)
		params[:content] = capture(&block)
		
		concat(
			render(
				:partial => "/nuniverse/menu_window",
				:locals => params
		), block.binding)
	end
	
	
	def main_menu_item item
		count = @source.connections.of_klass(item.classify).count
		lnk = link_to "#{count} #{(count > 1) ? item.pluralize : item.singularize  }", polymorphic_url(@source, :klass => item.capitalize, :display => @display, :page => 1), :title => "Show #{item.pluralize} connected to #{@source.name}"
		"<dd id= 'show_#{item}' class = '#{item}-klass #{(item == @klass) ? "activated" : ""}'>#{lnk}</dd>"
	end
	
	def home_link 
		link_to "< Back to your nuniverse", home_url, :class => "home_lnk"
	end
	
	def clear
		'<div class="delimiter"></div>'
	end
end
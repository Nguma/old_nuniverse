module NuniverseHelper
	
	def nuniverse(params = {}, &block)
		params[:content] = capture(&block)
		params[:selected] ||= ""
		concat(
			render(
				:partial => "/nuniverse/page",
				:locals => params
		), block.binding)		
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
	
	def empty_box
		"<div class='box hidden'>&nbsp;</div>"
	end
	
	def spinner
		render :partial => "/nuniverse/spinner"
	end
	
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
		params[:size] ||= 3
		params[:dom_classes] ||= []
		cols = []
		boxes.each_with_index do |box, i|
			(cols[i%params[:size]] ||= "") << box
		end
		cols.each_with_index do |col, i|
			col_html = render :partial => "/nuniverse/column", :locals => {
				:dom_class => params[:dom_classes][i] || "",
				:dom_id => "column_#{i}",
				:width => "#{(100/params[:size].to_i)}%",
				:col_content => cols[i]
			}
			html << col_html
		end
		
		html
	end
	
	# Service_is_nuniverse?
	# Returns true if selecte dservice / perspective is prioritary to nuniverse.
	def service_is_nuniverse?
		return true if @service == "you"
		return true if @service == "everyone"
		return false
	end
	
	
	def command(params)
		params[:command]  ||= "Add to #{params[:kind]}"
		link_to(params[:label],params[:command],:class => 'command')
	end
	
	def input(params)
		render :partial => "/nuniverse/input" , :locals => {
		  :source => params[:source]
		 }
	end
	
	def title_for(source, options ={})
		str = "<h1>#{source.title} "
		str << "<span class='service'> on #{@service}</span>" unless service_is_nuniverse?
		str << "</h1>"
		str
	end
	
	def content_for_item(item, params = {})
		if service_is_nuniverse?
			render :partial => "/taggings/#{item.kind}", :locals => {:tagging => item}  rescue render :partial => "/taggings/default", :locals => {:tagging => item}		
		else
			render :partial => "/taggings/#{@service}", :locals => {:tagging => item} 
		
		end
	end
end
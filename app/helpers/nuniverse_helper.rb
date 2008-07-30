module NuniverseHelper

	def render_section(section, params = {}, &block)
		params[:content] = capture(&block)
		params[:dom_classes] ||= ""
		params[:section] = section
		concat(
			render(
				:partial => "/nuniverse/section",
				:locals => params
		), block.binding)
	end
	
	def render_hat(params)
		if params[:subject]
			params[:avatar] ||= avatar_for(params[:subject])
			params[:label] ||= params[:subject].label
			params[:kind] ||= params[:subject].kind
			params[:description] ||= params[:subject].description
			params[:options] ||= link_to("edit", "/tags/edit/#{params[:subject].id}", :class => "edit")
		end
		return render :partial => "/nuniverse/hat", :locals => params
	end
	
	def connections_for(section)
		if section.is_web_service?
			return content_from_web_service(:service => section.perspective, :path => section.path)
		else
			return render(:partial => "/nuniverse/connections", :locals => {
					:connections => section.connections(:user => current_user),
					:path => section.path
				})
		end
	end
	
	
	def link_to_object(object, params = {})
		case object.service
		when "amazon"
			url = h "/ws/show?service=amazon&item=#{CGI::escape(object.property('amazon_id').rstrip)}"
		when "ebay"
			url = h "/ws/show?service=ebay&item=#{CGI::escape(object.property('ebay_id').rstrip)}"
		when "video"
			url = h "/ws/show?service=video&item=#{CGI::escape(object.url.rstrip)}&flashvars=#{CGI::escape(object.flashvars)}"
		else
			url = "/section_of/#{params[:path]}"
		end
		
		link_to(object.name.capitalize, url, :class =>"inner")
	end
	
	def link_to_ws_object(object, params = {})
		case params[:service]
		when "video"
			url = h "/ws/show?service=video&item=#{object.playUrl}"
			title = object.titleNoFormatting
		when "google"
			title = object.titleNoFormatting
			url = h "#{object.url.rstrip}"
			dom_c = "outer"
		when "amazon"
			title = h sanitize(object.title[0..100])
			url = h "/ws/show?service=amazon&item=#{object.id.rstrip}"
		when "ebay"
			title = h sanitize(object.title[0..100])
			url = h "/ws/show?service=ebay&item=#{object.item_id.rstrip}"
		else
			title = h object.title
			url = h "/ws/show?service=#{params[:service]}&item=#{object.url}"
		end
		link_to(title.capitalize, url, :class => dom_c || "inner")
	end
	
end
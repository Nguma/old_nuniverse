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
		return render(:partial => "/nuniverse/hat", :locals => params, :section => params[:section])
	end
	
	def connections_for(section, params = {})
		if section.is_web_service?
				partial = "/ws/#{section.perspective}"
		else
				partial = "/nuniverse/connections"
		end
		return render(:partial => partial, :locals => {
				:section => section,
				:connections => section.results(params)
			})
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
	
end
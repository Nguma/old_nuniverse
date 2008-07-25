module NuniverseHelper

	def render_section(section, params = {}, &block)
		params[:content] = capture(&block)
		params[:dom_classes] ||= ""
		params[:section] = section
		if section.no_wrap
			partial = "/nuniverse/content"
		else
			partial = "/nuniverse/section"	
		end
		concat(
			render(
				:partial => partial,
				:locals => params
		), block.binding)
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
			url = h "/ws/show?service=amazon&item=#{CGI::escape(object.url)}"
		when "ebay"
			url = h "/ws/show?service=ebay&item=#{CGI::escape(object.url)}"
		when "video"
			url = h "/ws/show?service=video&item=#{CGI::escape(object.url)}&flashvars=#{CGI::escape(object.flashvars)}"
		else
			url = "/section_of/#{params[:path]}"
		end
		
		link_to(object.name.capitalize, url, :class =>"main inner")
	end
	
end
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
					:connections => section.connections,
					:path => section.path
				})
		end
	end
	
end
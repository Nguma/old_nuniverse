# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
	def same_uri_with(params = {})
		new_uri = "/#{request.parameters[:controller]}/#{request.parameters[:action]}"
		new_uri << "/#{request.parameters[:id]}" if request.parameters[:id]
		new_uri << "?"
		new_params = request.parameters.clone
		new_params.delete('controller')
		new_params.delete('action')
		new_params.delete('id')
		params.each do |p|
			new_params[p[0]] = p[1].to_s
		end
		new_params.each do |p|
			new_uri << "#{p[0]}=#{p[1]}&"
		end
		new_uri
		
	end
	
	# this helper method takes a string, replaces all spaces with dashes, then strips out all non-letter, non-number, non-dashes
	# it's good for generating URL-friendly titles
	def strip_chars(string='')
	  return '' if string.blank?
	  string.gsub(' ','-').gsub(/[^a-z0-9\-]+/i, '')
	end

	def fields_for_source
		render :partial => "/application/source_fields"
	end
end

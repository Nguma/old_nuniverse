# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
	
	
	# this helper method takes a string, replaces all spaces with dashes, then strips out all non-letter, non-number, non-dashes
	# it's good for generating URL-friendly titles
	def strip_chars(string='')
	  return '' if string.blank?
	  string.gsub(' ','-').gsub(/[^a-z0-9\-]+/i, '')
	end
	
	def path_url(obj)
		visit_url(fact.parent.unique_name)
	end

	def fields_for_source(source = nil)
		source ||= @source
		render :partial => "/application/source_fields", :locals => {:source => source}
	end
	
	def fields_for_source(source = nil)
		source ||= @source
		render :partial => "/application/source_fields", :locals => {:source => source}
	end
	
	def render_plugin(box, data) 
		case box.mode
    when 'map'
      return render(
				:partial => "/stories/map", 
				:locals => {:locations => Location.gather(@story.sets[0].nuniverses)}
			)
    when 'text'
      return render(
				:partial => "/boxes/text_box", 
				:locals => {:box => box, :data =>  data}
			)			
    end
	end
end

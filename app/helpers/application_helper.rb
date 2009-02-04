# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
	
	
	# this helper method takes a string, replaces all spaces with dashes, then strips out all non-letter, non-number, non-dashes
	# it's good for generating URL-friendly titles
	def strip_chars(string='')
	  return '' if string.blank?
	  string.gsub(' ','-').gsub(/[^a-z0-9\-]+/i, '')
	end

	def fields_for_source(source = nil)
		source ||= @source
		render :partial => "/application/source_fields", :locals => {:source => source}
	end

	def tokenize(str)
		Nuniversal.tokenize(str).each do |token|
			n = Nuniverse.search(token.gsub('-',' '), :match_mode => :all)
			str = str.gsub(/\##{token}/,link_to(n.first.name, n.first)) if n.size == 1		
		end
		str
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

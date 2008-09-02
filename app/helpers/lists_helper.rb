module ListsHelper
	
	def link_to_list(list)
		link_to(list.label.capitalize, list)
	end
	
	def link_to_item(item)
		if item.object.kind == "bookmark"
			link_to("#{item.object.label.capitalize}", item.object.url)
		else
			link_to(item.object.label.capitalize, item)
		end
	
	end
	
	def breadcrumbs(path)
		starting_size = 17
		str = "<div class='breadcrumbs'>"
		str << link_to("< To your nuniverse", "/my_nuniverse", :style => "font-size:#{starting_size}px")
		path.taggings.each_with_index do |tagging,i|
			if tagging.object == current_user.tag
				str << link_to("< To your nuniverse", "/my_nuniverse")
			else
				str << link_to("< #{tagging.object.label.capitalize}", tagging, :style => "font-size:#{starting_size}px")
			end
		end
		str << "</div>"
		str
	end
	
	def sorting_options(elements, params = {})
		str = '<div class="sorting_options">'
		elements.each do |element|
			
			str << link_to(element[0],same_uri_with(:order => element[1]), :class => (params[:selected] == element[1]) ? "current" : "")
		end
		str << "</div>"
		str
	end
	
	def kind_options(tagging)
		return nil if tagging.owner != current_user
		return nil if tagging.kind
		options = ""
		options << link_to(
			image_tag("/images/icons/list_button.png", :alt => "this is a list"), 
			"/taggings/update/#{@tagging.id}?kind=list", :class => "list_button"
		)
		options << "<br/>"
		options << link_to(
			image_tag("/images/icons/location_button.png", :alt => "this is a location"), 
			"/taggings/update/#{@tagging.id}?kind=location", :class => "list_button"
		)
		options << "<br/>"
		options << link_to(
			image_tag("/images/icons/person_button.png", :alt => "this is a person"), 
			"/taggings/update/#{@tagging.id}?kind=person", :class => "list_button"
		)
		options
	end
end

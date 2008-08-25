module ListsHelper
	
	def link_to_list(list)
		link_to(list.label.capitalize, list)
	end
	
	def link_to_item(item)
		if item.object.url
			link_to("<span style='color:#679' class='kind'>Bookmark</span> #{item.object.label.capitalize}", item.object.url)
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
end

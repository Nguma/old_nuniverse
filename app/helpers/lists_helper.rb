module ListsHelper
	
	def link_to_list(list)
		link_to(list.label.capitalize, list)
	end
	
	def link_to_item(item, params = {})
		if item.object.kind == "bookmark"
			link_to("#{item.object.label.capitalize}", item.object.url)
		else
			url = "/taggings/#{item.id}?"
			url << "list=#{params[:list].label}" if params[:list]
			link_to(item.object.label.capitalize, url)
		end
	
	end
	
	def breadcrumbs(tagging)
		starting_size = 17
		str = "<div class='breadcrumbs'>"
		str << link_to("< To your nuniverse", "/my_nuniverse", :style => "font-size:#{starting_size}px")
		# path.taggings.each_with_index do |tagging,i|
		# 		if tagging.object == current_user.tag
		# 			str << link_to("< To your nuniverse", "/my_nuniverse")
		# 		else
		# 			str << link_to("< #{tagging.label.capitalize}", tagging, :style => "font-size:#{starting_size}px")
		# 		end
		# 	end
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
	
	def list(params)
		params[:dom_class] ||= ""
		params[:kind] ||= params[:source].label.singularize
		params[:title] ||= params[:kind] ? params[:kind].pluralize : ""
		params[:items] ||= params[:source].items
		params[:toggle] ||= "##{params[:kind].downcase.gsub(" ","_")} " 
		params[:dom_id] ||= params[:title].pluralize
		render :partial => "/taggings/list_box", :locals => params
	end
	
	def lists_for(source, options = {})
		boxes = []
		# (options[:plus] ||= []).each do |item|
		# 	boxes << List.new(:creator => current_user, :label => item)
		# end
		source.lists.each_with_index do |item,i|
			boxes << list(:source => item) 
		end
		if options[:add_box]
			boxes << "#{render :partial => options[:add_box]}"
		end
		boxes
	end
	
	def people_box
		list(:source => List.new(:creator => current_user, :label => "People"))
	end
	
	def locations_box
		list(:source => List.new(:creator => current_user, :label => "Places"))
	end
	
	def bookmarks_box
		list(:source => List.new(:creator => current_user, :label => "Bookmarks"))
	end
	
	def ad_box
		render :partial => "/nuniverse/ads"
	end
	
	def new_item_box
		render :partial => "/taggings/new_item"
	end
	
	def contributors_box(source)
		contributors = source.contributors(:page => @page, :per_page => 5)
		render :partial => "/nuniverse/contributors", :locals => {:source => source, :contributors => contributors}
	end
end

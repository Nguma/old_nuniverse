module ListsHelper
	
	def list_hat(list)
		title = ""
		title << "#{list.tag.label.capitalize}: " if list.tag
		title << list.label.capitalize
		render :partial => "hat", :locals => {:title => title}
	end
	
	def add_new_button(list)
		command = "##{list.label} "
		render :partial => "add_new_button", :locals => {:command => command}
	end
	
	def link_to_item(item, params = {})
		
		if item.object.kind == "bookmark"
			link_to("#{item.object.label.capitalize}", item.object.url)
		else
			
			if params[:source]
				if params[:source].tag
					url = item_with_tag_url(params[:source].tag,params[:source].label,  item)
				else
					url = item_url(params[:source].label, item)
				end
			else
				url = item_url(item)
			end
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
	
	def sorting_options(params = {})
		elements = [['By Name', 'name'],['By Latest', 'latest'],['By Rank', 'rank']]
		str = '<ul class="tabs">'
		elements.each do |element|
			str << "<li class=' #{params[:selected] == element[1] ? "current" : ""}'>"
			str << link_to(element[0], listing_url(params[:source].label, :order => element[1]))
			str << "</li>"
		end
		str << "</ul>"
		str
	end
	
	def view_options(source, params = {})
		str = ""
		options = [['View as list', 'list'],['View in images', 'image']]
		options.each do |option|
			str << "<li class ='#{params[:selected] == options[1] ? "current" : ""}'>"
			str << link_to(option[0], listing_url(:list => source.label, :tag => source.tag, :mode => option[1]))
			str << "</li>"
		end
		render :partial => "view_options", :locals => {:options => str} 
	end
	
	def link_to_list(list, options = {})
		title = options[:title] || list.label
		if list.tag
			link_to title.capitalize, listing_with_tag_url(list.tag,list.label)
		else
			link_to title.capitalize, listing_url(list.label)
		end
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
	
	def people_box(params = {})
		list(:source => List.new(:creator => @current_user, :label => "People", :tag => params[:source] || nil))
	end
	
	def locations_box(params = {})
		list(:source => List.new(:creator => @current_user, :label => "Locations", :tag => params[:source] || nil))
	end
	
	def bookmarks_box(params = {})
		list(:source => List.new(:creator => @current_user, :label => "Bookmarks", :tag => params[:source] || nil))
	end
	
	def comments_box(params = {})
		render :partial => "/taggings/comments", :locals => {:source => params[:source]}
	end
	
	def ad_box
		render :partial => "/nuniverse/ads"
	end
	
	def new_item_box
		render :partial => "/taggings/new_item"
	end
	
	def new_list_button
		render :partial => "/taggings/new_list"
	end
	
	def contributors_box(params = {})
		params[:source] ||= current_user
		contributors = params[:source].contributors(:page => @page, :per_page => 5)
		
		render :partial => "/nuniverse/contributors", :locals => {:source => params[:source], :contributors => contributors}
	end
	
	def map_box(source)
		@map = map(:source => source)
		if @map
			return render(:partial => "/nuniverse/map_box", :locals => {:map => @map})
		elsif !source.is_a?(List)
			return render(:partial => "/nuniverse/localize", :locals => {:items => google_localize(source)})
		end
	end
	
	def expander_icon
		image_tag('/images/icons/expander.png', :alt => 'expand', :class => "expander")
	end
end

module ListsHelper
	
	def list_hat(list)
		title = ""
		title << "#{list.tag.label.capitalize}: " if list.tag
		title << list.label.capitalize
		render :partial => "hat", :locals => {:title => title}
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
	
	def render_item(item, params = {})
		render :partial => "/lists/item", :locals => {:item => item, :source => params[:source] || nil}
	end
	
	def breadcrumbs(params = {})
		starting_size = 17
		str = "<div class='breadcrumbs'>"
		str << link_to("< To your nuniverse", "/my_nuniverse", :style => "font-size:#{starting_size}px")
		str << link_to("< #{params[:list].title}", listing_url(:list => params[:list].label, :tag => params[:list].tag)) if params[:list]
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
		options = [['View as list', 'list'],['View in icons','icon'],['View in images', 'image']]
		options.each do |option|
			str << "<li class ='#{params[:selected] == options[1] ? "current" : ""}'>"
			str << link_to(image_tag("/images/icons/view_as_#{option[1]}.png"), listing_url(:list => source.label, :tag => source.tag, :mode => option[1]))
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
		params[:command] ||= "#{params[:kind]}" 
		params[:dom_id] ||= params[:title].pluralize
		render :partial => "/taggings/list_box", :locals => params
	end
	
	def lists_for(source, options = {})
		boxes = []
		source.lists.each_with_index do |item,i|
			boxes << list(:source => item) 
		end
		if options[:add_box]
			boxes << "#{render :partial => options[:add_box]}"
		end
		boxes
	end
	
	def boxes_for(items, params = {})
		boxes = []
		items.each_with_index do |item, i|
			boxes << "#{render :partial => "/taggings/box", :locals => {:item => item, :source => params[:source] || nil}}"
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
		tag = params[:source].is_a?(Tagging) ? params[:source].object : params[:source]
		list(:source => List.new(:creator => @current_user, :label => "Bookmarks", :tag => tag))
	end
	
	def comments_box(params = {})
		render :partial => "/taggings/comments", :locals => {:source => params[:source]}
	end
	
	def property_box(params = {})
		render :partial => "/taggings/properties", :locals => {:source => params[:source],:properties => params[:source].properties}
	end
	
	def ad_box
		render :partial => "/nuniverse/ads"
	end
	
	def new_item_box
		render :partial => "/taggings/new_item"
	end
	
	def add_new_button(list)
		command = "#{list.label.singularize}"
		render :partial => "add_new_button", :locals => {:command => command}
	end
	
	def new_list_button
		render :partial => "/taggings/new_list"
	end
	
	def contributors_box(params = {})
		params[:source] ||= current_user
		permissions = params[:source].permissions(:page => @page, :per_page => 10)
		
		render :partial => "/nuniverse/contributors", :locals => {:source => params[:source], :permissions => permissions}
	end
	
	def map_box(source, params = {})
		@map = map(:source => source, :page => params[:page] || 1)
		if @map
			return render(:partial => "/nuniverse/map_box", :locals => {:map => @map, :source => source})
		elsif !source.is_a?(List)
			# items = google_localize(source)
			items = []
			return render(:partial => "/nuniverse/localize", :locals => {:items => items})
		end
	end
	
	def expander_icon
		image_tag('/images/icons/expander.png', :alt => 'expand', :class => "expander")
	end
end

module ListsHelper
	
	def list_hat(list)
		title = ""
		title << "#{list.tag.label.capitalize}: " if list.tag
		title << list.label.capitalize
		render :partial => "hat", :locals => {:title => title}
	end
		
	def link_to_item(item, params = {})	
		list = params[:kind] ? params[:kind] : item.kind 	
		params[:title] ||= item.label.capitalize
		if item.kind == "bookmark" 
			link_to("#{params[:title]}", item.url, :target => "_blank")
		else
			link_to(params[:title], item_url(:id => item.id, :list => list, :mode => params[:mode] || @mode, :service => @service))
		end
	end
	
	def render_item(item, params = {})
		params[:source] ||= nil
		params[:kind] ||= nil
		params[:item] = item
		render :partial => "/lists/item", :locals => params
	end
	
	def render_item_box(item, params = {})
		params[:item] = item
		render :partial => "/lists/item_box", :locals => params
	end
	
	def breadcrumbs_for(source, params = {})
		breadcrumbs = []
		breadcrumbs << link_to("< To your nuniverse", "/my_nuniverse")
		case source.class.to_s
		when 'Tagging'
			if @list
			breadcrumbs << link_to("< #{@list.tag.title}", tag_url(:id => @list.tag.id)) if @list.tag
			breadcrumbs << link_to_list(@list, :title =>"< #{@list.label}")
		end
		when 'List'
			breadcrumbs << link_to("< #{source.tag.title}", tag_url(:id =>source.tag.id)) if source.tag
		when 'Tag'
			breadcrumbs << link_to("< #{source.kind.split('#').last}", listing_url(:list => source.kind.split('#').last))
		else
			
		end
		render :partial => "/nuniverse/breadcrumbs", :locals => {:breadcrumbs => breadcrumbs}
	end
	
	def sorting_options(params = {})
		options = [['Name', 'by_name'],['Latest', 'by_latest'],['Vote', 'by_vote']]
		params[:source] ||= @source
		params[:selected] ||= @order
		render :partial => "/lists/sorting_options", :locals => {:options => options, :source => params[:source], :selected => params[:selected]}

	end
	
	def display_options(params = {})
		options = [['As list', 'list'],['As cards','card'],['As images', 'image']]
		params[:selected] ||=  @mode
		params[:source] ||= @source
		render :partial => "/lists/display_options", :locals => {:options => options, :source => params[:source], :selected => params[:selected]} 
	end
	
	def perspectives(params = {})
		list_label = @list.label rescue params[:source].kind
		
		if params[:source].is_a?(Tagging)
			perspectives = [
				["you",	item_url(:id => params[:source].id, :list => list_label, :mode => @mode,  :service => "you"), "you"], 
				["all contributors",	item_url(:id => params[:source].id, :list =>  list_label, :mode => @mode,  :service => "everyone"), "everyone"],
				["Google",item_url(:id => params[:source].id, :list =>  list_label, :mode => @mode,  :service => "google"), "google"],
				["Amazon", item_url(:id => params[:source].id, :list =>  list_label, :mode => @mode,  :service => "amazon"), "amazon"],
				["Youtube", item_url(:id => params[:source].id, :list =>  list_label,:mode => @mode,   :service => "youtube"), "youtube"]
			]
		else
			perspectives = [
				["you", listing_url(:list => @list.label, :tag => @list.tag, :mode => @mode,  :order => @order || nil, :page => 1, :service => "you"), "you"],
				["everyone", listing_url(:list => @list.label, :tag => @list.tag, :mode => @mode,  :order => @order || nil, :page => 1, :service => "everyone"), "everyone"],
			]
		end
		render :partial => "/taggings/perspectives", :locals => {:perspectives => perspectives, :source => params[:source]}
	end
	
	
	def link_to_list(list, options = {})
		title = options[:title] || list.label
		title = title.singularize if options[:item_size] && options[:item_size] <= 1
		link_to title.capitalize, listing_url(:list => list.label, 
																					:tag => list.tag, 
																					:mode => options[:mode] || @mode, 
																					:page => options[:page] || @page, 
																					:order => options[:order] || @order, 
																					:service => options[:service] || @service
																), :class => "link_to_list"
	end
	
	def list(params)
		params[:dom_class] ||= ""
		params[:kind] ||= params[:source].label.singularize.downcase
		params[:title] ||= params[:kind] ? params[:kind].pluralize : ""
		params[:items] ||= params[:source].items
		params[:command] ||= "#{params[:kind]}" 
		params[:order] ||= "latest"
		params[:dom_id] ||= params[:title].pluralize
		params[:ord] = cycle('even','odd')
		render :partial => "/taggings/#{params[:kind]}_box", :locals => params rescue render :partial => "/taggings/list_box", :locals => params
		#render :partial => "/taggings/#{params[:kind]}_box", :locals => params
	end
	
	def lists_for(source, options = {})
		boxes = []
		source.lists(:user => current_user).each_with_index do |list,i|
			boxes << list(:source => list) 
		end
		boxes
	end
	
	def boxes_for(items, params = {})
		params[:source] ||= @source
		params[:kind] ||= params[:source].label
		boxes = []
		items.each_with_index do |item, i|
			case @mode 
			when "card"
				boxes << render_item_box(item, params)
			when "image"
				boxes << "#{render :partial => "/images/box", :locals => {:item => item, :source => params[:source]}}"
			else	
			end
		end
		boxes
	end
	
	def pagination_box(params) 
		render :partial => "/lists/pagination", :locals => {:items => params[:items]} 
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
	
	def image_box(params = {})
		params[:source] ||= @source
		params[:expanded] ||= false
		render :partial => "/taggings/image_box", :locals => params
	end
	
	def comments_box(params = {})
		render :partial => "/taggings/comments", :locals => {:source => params[:source]}
	end
	
	def property_box(params = {})
		render :partial => "/taggings/properties", :locals => {:source => params[:source],:properties => params[:source].properties}
	end
	
	def account_box
		render :partial => "/users/account"
	end
	
	def ad_box
		render :partial => "/nuniverse/ads"
	end
	
	def empty_box
		render :partial => "/nuniverse/empty_box", :locals => {:source => @source}
	end
	
	def command_box(label,action, options = {})
		str = "<div class='command_box'>"
		str << command(:label => label, :command => action)
		str << "</div>"
		str		
	end
	
	def new_item_box
		render :partial => "/taggings/new_item"
	end
	
	def address_box
		render :partial => "/taggings/address_box"
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
			return render(:partial => "map_box", :locals => {:map => @map, :source => source})
		elsif !source.is_a?(List)
			# items = google_localize(source)
			items = []
			return render(:partial => "/nuniverse/localize", :locals => {:items => items})
		end
	end
	
	def expander_icon
		link_to("#{image_tag('/images/icons/expander.png', :alt => 'expand', :class => 'expand_icon', :title => 'expand')} #{image_tag('/images/icons/collapser.png', :alt => 'collapse', :class => 'collapse_icon', :title => 'collapse')}", "#", :class => "expander")
	end
	
	def content_size(size)
		"<span class='size'>#{size}</span>"
	end
	
	def options_for_kind(list)
		options = []
		case list.label.singularize
		when "Video"
			options << command(:label => "Find videos on google", :command => "google videos")
		when "Bookmark"
			options << command(:label => "Find on google", :command => "Find on google")
		when "Item"
			options << command(:label => "Find items on Amazon", :command => "Find on amazon")
		when "Address"
			options << command(:label => "Find Address on google", :command => "localize")
		else
		end
		options
	end
	
	def pagination_box(items)
		render :partial => "/lists/pagination_box", :locals => {:items => items}
	end
	
	def list_options(params = {})
		params[:items] ||= @source.items
		render :partial => "/lists/options", :locals => params
	end
end

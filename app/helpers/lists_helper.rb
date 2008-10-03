module ListsHelper
	
	def list_hat(list)
		title = ""
		title << "#{list.tag.label.capitalize}: " if list.tag
		title << list.label.capitalize
		render :partial => "hat", :locals => {:title => title}
	end
		
	def link_to_item(item, params = {})	
		list = params[:kind] ? params[:kind] : item.kind 	
		if item.kind == "bookmark"
			link_to("#{item.object.label.capitalize}", item.object.url)
		else
			link_to(item.label.capitalize, item_url(:id => item.id, :list => list))
		end
	
	end
	
	def render_item(item, params = {})
		params[:source] ||= nil
		params[:kind] ||= nil
		params[:item] = item
		render :partial => "/lists/item", :locals => params
	end
	
	def breadcrumbs_for(source, params = {})
		breadcrumbs = []
		breadcrumbs << link_to("< To your nuniverse", "/my_nuniverse")
		case source.class.to_s
		when 'Tagging'
			breadcrumbs << link_to("< #{@list.tag.title}", tag_url(:id => @list.tag.id)) if @list.tag
			breadcrumbs << link_to("< #{@list.label}", listing_url(:list => @list.label, :tag => @list.tag))
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
		render :partial => "/lists/sorting_options", :locals => {:options => options, :source => params[:source], :selected => params[:selected]}

	end
	
	def display_options(params = {})
		options = [['As list', 'list'],['As cards','card'],['As images', 'image']]
		params[:selected] ||= 'list'
		render :partial => "display_options", :locals => {:options => options, :source => params[:source], :selected => params[:selected]} 
	end
	
	def perspectives(params = {})
		list_label = @list.label rescue params[:source].kind
		perspectives = [
			["you",	item_url(:id => params[:source].id, :list => list_label, :service => "you"), "you"], 
			["all contributors",	item_url(:id => params[:source].id, :list =>  list_label, :service => "everyone"), "everyone"],
			["Google",item_url(:id => params[:source].id, :list =>  list_label, :service => "google"), "google"],
			["Amazon", item_url(:id => params[:source].id, :list =>  list_label, :service => "amazon"), "amazon"],
			["Youtube", item_url(:id => params[:source].id, :list =>  list_label, :service => "youtube"), "youtube"]
		]
		render :partial => "/taggings/perspectives", :locals => {:perspectives => perspectives, :source => params[:source]}
	end
	
	
	def link_to_list(list, options = {})
		title = options[:title] || list.label
		title = title.singularize if options[:item_size] && options[:item_size] <= 1
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
		params[:order] ||= "latest"
		params[:dom_id] ||= params[:title].pluralize
		render :partial => "/taggings/list_box", :locals => params
	end
	
	def lists_for(source, options = {})
		boxes = []
		source.lists(:user => current_user).each_with_index do |item,i|
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
	
	def image_box(params)
		object = params[:source].is_a?(User) ? params[:source].tag : params[:source].object
		render :partial => "/taggings/image", :locals => {:object => object}
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
end

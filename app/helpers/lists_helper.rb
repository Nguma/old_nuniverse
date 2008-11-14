module ListsHelper
	
	def breadcrumbs(params = {})
		params[:source] ||= @source
		breadcrumbs = []
		breadcrumbs << link_to("< To your nuniverse", "/my_nuniverse")
		case params[:source].class.to_s
		when 'List'
			if !@list.context.blank?
				breadcrumbs << link_to("< #{@list.context.capitalize}", tag_url(params[:source].tag, :kind => params[:source].context), :mode => @mode) 
				breadcrumbs << link_to("< #{@list.kind.pluralize.capitalize}", listing_url(:kind => params[:source].kind.pluralize, :perspective => @user.login, :mode => @mode)) 
			end
		when 'Tag'
			breadcrumbs << link_to("< #{@list.title.capitalize}", listing_url(:kind => params[:source].title, :user => @user.login, :mode => @mode)) unless @list.context.blank?
			breadcrumbs << link_to("< #{@list.kind.pluralize.capitalize}", listing_url(:kind => params[:source].kind.pluralize, :perspective => @user.login)) 
		else
			
		end
		render :partial => "/nuniverse/breadcrumbs", :locals => {:breadcrumbs => breadcrumbs}
	end
	
	def list_hat(list)
		title = ""
		title << "#{list.tag.label.capitalize}: " if list.tag
		title << list.label.capitalize
		render :partial => "hat", :locals => {:title => title}
	end
		
	def link_to_item(item, params = {})	
		item = item.is_a?(Tagging) ? item.object : item
		kind = params[:kind] ? params[:kind] : item.kind 	
		params[:service] ||= @service
		params[:title] ||= item.label.capitalize
		if item.kind == "bookmark" || !item.service.nil?
			link_to(params[:title], item.url, :target => "_blank")
		else
			link_to(params[:title], tag_url(item, :kind => kind, :service => params[:service], :mode => params[:mode] || @mode))
		end
	end
	
	def link_to_list(list, options = {})
		title = options[:title] || list.label
		title = title.singularize if options[:item_size] && options[:item_size] <= 1
		
		link_to title.capitalize, listing_url(list.uri_name, 
																					:perspective => options[:user] || @perspective.tag.label,
																					:mode => options[:mode] || @mode, 
																					:page => options[:page] || @page, 
																					:order => options[:order] || @order
																					
																), :class => "link_to_list"
	end
	
	def list(params)
		params[:dom_class] ||= ""
		params[:source] ||= @source
		params[:kind] ||= params[:source].label.singularize.downcase
		params[:title] ||= params[:kind] ? params[:kind].pluralize : ""
		params[:subject] ||= params[:source].tag
		params[:items] ||= connections(:perspective => @perspective, :source => params[:source], :kind => params[:kind], :subject => params[:subject]) 
		params[:command] ||= params[:kind] 
		params[:order] ||= "latest"
		params[:dom_id] ||= params[:title].pluralize
		params[:ord] = cycle('even','odd')
		render :partial => "/boxes/#{params[:kind]}_box", :locals => params rescue render :partial => "/boxes/list_box", :locals => params
		#render :partial => "/taggings/#{params[:kind]}_box", :locals => params
	end
	
	def render_item(item, params = {})
		params[:source] ||= @source
		params[:kind] ||= nil
		params[:item] = item
		render :partial => "/lists/item", :locals => params
	end
	
	def render_item_box(item, params = {})
		params[:item] = item
		params[:item_classes] = ""
			
		personal = item.personal.to_i rescue nil
		if personal	
			params[:item_classes] <<  (item.public ? ' personal' : ' private')
		end

		
		render :partial => "/lists/item_box", :locals => params
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
		return if @list.nil?
		kind = @list.kind rescue params[:source].kind
		perspectives = [@current_user.self_perspective, @everyone.perspectives.favorites,current_user.perspectives.favorites].flatten
		render :partial => "/nuniverse/perspectives", :locals => {:perspectives => perspectives}
	end
	
	def lists_for(source, options = {})
		presets =  presets(@tag.kind)
		presets << source.lists(:user => current_user).collect {|c| c.label.downcase}
		make_lists(presets.flatten.uniq.sort)
	end
	
	def boxes_for(items, params = {})
		params[:source] ||= @source
		params[:kind] ||= params[:source].kind
		
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
	
	def make_lists(list_names)
		lists = []
		params[:source] ||= @source
		list_names.each do |list|
			lists << list(:source => List.new(:label => list, :creator => current_user, :tag => (@source == current_user) ? nil : @source.object ))
		end
		lists
	end
	
	def image_box(params = {})
		params[:source] ||= @source
		params[:source] = params[:source].is_a?(Tagging) ? params[:source].object : params[:source]
		params[:expanded] ||= false
		render :partial => "/boxes/image_box", :locals => params
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
		options[:label] = label
		options[:command] = action
		
		str = "<div class='command_box'>"
		str << command(options)
		str << "</div>"
		str		
	end
	
	def reviews_box(params = {})

		render :partial => "/boxes/reviews", :locals => {:reviews => reviews}
	end
	
	def address_box
		render :partial => "/boxes/address_box"
	end
	
	def new_item_box
		render :partial => "/boxes/new_item"
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
		# permissions = params[:source].permissions(:page => @page, :per_page => 10)
		
		# render :partial => "/nuniverse/contributors", :locals => {:source => params[:source], :permissions => permissions}
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
		'<span class="size">#{size}</span>'
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

ActionController::Routing::Routes.draw do |map|
  # map.resources :rankings
  # 
  #   map.resources :lists
  # 
  #   map.resources :tags do |tag|
  #     tag.resource :image
  #   end
			map.resources :lists
  		map.resource :sessions
   		map.resources :taggings
   		map.resource :user, :member => { :suspend   => :put,
  	                                   :unsuspend => :put,
    	                                 :purge     => :delete }
    
    	map.activate '/activate', 
    		:controller => 'users', 
    		:action => 'activate'		
    		
    	map.activate '/activate/:activation_code', 
    		:controller => 'users', 
    		:action => 'activate'
    		
    	map.signup '/signup', :controller => 'users', :action => 'new'
    	map.login '/login', :controller => 'sessions', :action => 'new'
    	map.logout '/logout', :controller => 'sessions', :action => 'destroy' 
   		
    		
    	map.restricted "/restricted",
    		:controller => "application",
    		:action => 'restricted'
 	
	  	map.with_options :controller => 'application' do |m|
				m.about "/about", :action => "about"
	  		m.thank_you '/thank_you', :action => 'thank_you' 
	  		m.feedback '/feedback', :action => 'feedback'
	  		m.beta '/beta', :action => 'beta'
	  	end
  			
	  	map.with_options :controller => 'users' do |m|
	  		m.home '/my_nuniverse', :action => 'show'
				m.all '/my_nuniverse/all_items', :action => 'show', :mode => 'cards' 
	  		m.upgrade '/upgrade', :action => 'upgrade'
	  	end
  	
	  	map.with_options :controller => 'lists', :action => 'show', :path_prefix => '/my_nuniverse' do |m|
				
	  		m.item_with_tag '/:tag/:kind/item/:id/service/:service', :controller => 'taggings', :requirements => {:tag => /\d+/}
				m.tag '/all_items/:id', :controller => 'tags'
	  		
				m.item '/all/:kind/item/:id/service/:service', :controller => 'tags',  :requirements => { :service => /\w+/}
				m.item '/all/:kind/item/:id', :controller => 'tags'
				
	  		m.with_options :page => 1, :order => "by_name" do |page|
					page.listing '/all/:kind/in/:mode/:page/:order', :requirements => {:mode => /image/, :page => /\d+/}
					page.listing '/all/:kind/:page/:order/according-to/:service', :requirements => {:page => /\d+/, :service => /\w+/}
					page.listing '/all/:kind/:page/:order', :requirements => {:page => /\d+/}
					
					page.listing_with_tag '/:tag/:kind/:page/:order', :requirements => {:tag => /\d+/, :page => /\d+/}
					
					#page.listing_in_images '/all/:list/in_images/:page/:order', :mode => 'image', :requirements => {:page => /\d+/, :tag => nil}
					page.list_in_cards	'/:tag/:kind/in_cards/:page/:order', :mode => 'card', :requirements => {:tag => /\d+/,:page => /\d+/}
					page.list_in_images '/:tag/:kind/in_images/:page/:order', :mode => 'image', :requirements => {:tag => /\d+/,:page => /\d+/}
				end
	  					
	  	
	  	end
	
	# map.resources :admin, :page => 1 do |admin|
	# 	admin.resources :users, :name_prefix => "user_"
	# 	admin.resources :permissions, :name_prefix => "permission_"
	# end

			

  # 		
  	map.with_options :controller => 'taggings' do |m|
  		m.rate '/rate/:id/:stars', :action => 'rate'
  		m.map '/locate/:id', :action => 'show', :service => 'map'
  		m.bookmark '/bookmark/:path', :action => 'bookmark'
  	end
  # 	

	map.with_options :controller => 'nuniverse', :action => 'command',  :tag => nil  do |m|
		m.command '/command'
		
		m.command '/command/:command'
		
		m.command '/command/:command/:input'
		m.command_with_item '/command/:command/with_item/:item', :requirements => {:item => /\d+/}
		m.command_with_id '/command/:command/with_id/:id',  :requirements => {:id => /\d+/}
		m.suggest '/suggest/:command', :action => 'suggest'
		m.suggest '/suggest/:command/:input', :action => 'suggest'
	end


  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
   map.root :controller => "nuniverse"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

	#map.connect '*path', :controller => 'application', :action => 'redirect_to_default'
end

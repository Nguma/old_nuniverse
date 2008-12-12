ActionController::Routing::Routes.draw do |map|
	map.resources :kinds

	map.resource :sessions
 	map.resources :taggings
	map.resources :tags
	map.resources :images
	map.resources :groups
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
  	
	  	map.with_options :controller => 'tags', :action => 'show' do |m|
		
	  		m.with_options :page => 1, :order => "by_name" do |page|
					page.listing_with_tag '/:tag/:kind/:page/:order', :requirements => {:tag => /\d+/, :page => /\d+/}
					page.list_in_cards	'/:tag/:kind/in_cards/:page/:order', :mode => 'card', :requirements => {:tag => /\d+/,:page => /\d+/}
					page.list_in_images '/:tag/:kind/in_images/:page/:order', :mode => 'image', :requirements => {:tag => /\d+/,:page => /\d+/}
				end
	  	end
			

	
 	map.with_options :controller => 'taggings' do |m|
 		m.rate '/rate/:id/:stars', :action => 'rate'
 		m.map '/locate/:id', :action => 'show', :service => 'map'
 		m.bookmark '/bookmark/:path', :action => 'bookmark'
 	end 	

	map.with_options :controller => 'nuniverse', :action => 'command',  :tag => nil  do |m|
		m.command '/command'
		m.command '/command/:command'
		m.command '/command/:command/:input'
		m.command_with_item '/command/:command/with_item/:item', :requirements => {:item => /\d+/}
		m.command_with_id '/command/:command/with_id/:id',  :requirements => {:id => /\d+/}
		m.suggest '/suggest', :action => 'suggest'
		m.suggest '/suggest/:command/:input', :action => 'suggest'
	end
	
	map.create_tag "/create_tag", :controller => "tags", :action => "create"
	map.konnect "/connect/:subject/:object", :controller => "connections", :action => "connect", :requirements => {:subject => /\d+/}
	map.create_and_connect "/connect/:object", :controller => "connections", :action => "connect"
	map.disconnect "/disconnect/:id", :controller => "connections", :action => "disconnect"
	
	map.visit "/nuniverse-of/:id/according-to/:perspective", :controller => "tags", :action => "show"
	map.add_to_nuniverse "/add-to-favorites/:id", :controller => "connections", :action => "add_to_favorites"
	map.remove_from_nuniverse "/remove-from-favorites/:id", :controller => "connections", :action => "remove_from_favorites"
	map.preview "/preview/:id", :controller => "connections", :action => "preview"
	map.send_email "/send_email/:id", :controller => "tags", :action => "send_email"

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
   map.root :controller => "nuniverse"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

	#map.connect '*path', :controller => 'application', :action => 'redirect_to_default'
end

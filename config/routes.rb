ActionController::Routing::Routes.draw do |map|
  # map.resources :rankings
  # 
  #   map.resources :lists
  # 
  #   map.resources :tags do |tag|
  #     tag.resource :image
  #   end
			map.resources :lists
  		map.resources :sessions
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

    	map.tags "/about/:label",
    		:controller => "tags",
    		:action => "show"
    
    		
    	map.restricted "/restricted",
    		:controller => "application",
    		:action => 'restricted'
 	
	  	map.with_options :controller => 'application' do |m|
	  		m.thank_you '/thank_you', :action => 'thank_you' 
	  		m.feedback '/feedback', :action => 'feedback'
	  		m.beta '/beta', :action => 'beta'
	  	end
  			
	  	map.with_options :controller => 'users' do |m|
	  		m.home '/my_nuniverse', :action => 'show'
	  		m.upgrade '/upgrade', :action => 'upgrade'
	  	end
  	
	  	map.with_options :controller => 'lists', :action => 'show', :path_prefix => '/my_nuniverse' do |m|
				
	  		m.item_with_tag '/:tag/:list/item/:id', :controller => 'taggings', :requirements => {:tag => /\d+/}
	  		m.item '/all/:list/item/:id', :controller => 'taggings'
	
	  		m.with_options :page => 1, :order => nil do |page|
					page.listing '/all/:list/in/:mode/:page/:order', :requirements => {:mode => /image/, :page => /\d+/}
					page.listing '/all/:list/:page/:order', :requirements => {:page => /\d+/}
					page.listing_with_tag '/:tag/:list/:page/:order', :requirements => {:tag => /\d+/, :page => /\d+/}
					
					#page.listing_in_images '/all/:list/in_images/:page/:order', :mode => 'image', :requirements => {:page => /\d+/, :tag => nil}
					page.list_in_images '/:tag/:list/in_images/:page/:order', :mode => 'image', :requirements => {:tag => /\d+/,:page => /\d+/}
				end
	  					
	  	
	  	end
	
	# map.resources :admin, :page => 1 do |admin|
	# 	admin.resources :users, :name_prefix => "user_"
	# 	admin.resources :permissions, :name_prefix => "permission_"
	# end

			

  # 		
  	map.with_options :controller => 'taggings' do |m|
  		m.google '/google/:id', :action => 'show', :service => 'google'
  		m.rate '/rate/:id/:stars', :action => 'rate'
  		m.map '/locate/:id', :action => 'show', :service => 'map'
  		m.bookmark '/bookmark/:path', :action => 'bookmark'
  	end
  # 	
  	map.command '/command', 
  		:controller => 'nuniverse',
  		:action => 'command'


  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
   map.root :controller => "nuniverse"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

	map.connect '*path', :controller => 'application', :action => 'redirect_to_default'
end

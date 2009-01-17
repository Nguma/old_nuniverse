ActionController::Routing::Routes.draw do |map|
  map.resources :facts

  map.resources :stories

	map.resources :kinds

	
 	map.resources :taggings
	map.resources :comments
	map.resources :tags
	map.resources :nuniverses
	map.resources :polycos
	map.confirm_connection "/confirm-connection/:id/with/:subject_id/:subject_type", :controller => "Polycos", :action => "update"
	map.resources :images
	map.resources :bookmarks

	map.resources :videos
	map.signup '/signup', :controller => 'users', :action => 'new'
 	map.register '/register', :controller => 'users', :action => 'create'
	map.resources :users
 	map.resource :user, :member => { :suspend   => :put,
	                                   :unsuspend => :put,
  	                                 :purge     => :delete }
    
  map.activate '/activate', 
 		:controller => 'users', 
 		:action => 'activate'		
 		
 	map.activate '/activate/:activation_code', 
 		:controller => 'users', 
 		:action => 'activate'
 		

 	map.login '/login', :controller => 'sessions', :action => 'new'
 	map.logout '/logout', :controller => 'sessions', :action => 'destroy' 
	
	map.session '/session', :controller => 'sessions', :action => 'create'
		
 		
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
				m.account '/account', :action => 'account'
	  		m.upgrade '/upgrade', :action => 'upgrade'
		
	  	end
  	

			
	# map.konnect "/connect/:subject_type/:subject_id/with/:object_type/:object_id", :controller => "polycos", :action => "connect"
	
	
	map.locate "/locate", :controller => "locations", :action => "find"
	
	map.create_tag "/create_tag", :controller => "tags", :action => "create"
	map.make_connection "/make_connection/from/:object_type/:object_id/to/:subject_type/:subject_id", :controller => "polycos", :action => "connect"
	# map.konnect "/connect/:subject/:object", :controller => "connections", :action => "connect", :requirements => {:subject => /\d+/}
	# map.create_and_connect "/connect/:object", :controller => "connections", :action => "connect"
	map.disconnect "/disconnect/:id", :controller => "connections", :action => "disconnect"
	
	map.suggest "/suggest-a-nuniverse", :controller => "nuniverses", :action => "suggest"
	
	map.share_story "/share-story/:id", :controller => "stories", :action => "share"

	
	# map.visit "/nuniverse-of/:id/according-to/:perspective", :controller => "tags", :action => "show"
	map.add_to_nuniverse "/add-to-favorites/:id", :controller => "connections", :action => "add_to_favorites"
	map.remove_from_nuniverse "/remove-from-favorites/:id", :controller => "connections", :action => "remove_from_favorites"
	map.preview "/preview/:id", :controller => "connections", :action => "preview"
	map.send_email "/send_email/:id", :controller => "tags", :action => "send_email"
	
	map.tutorial_url "/tutorial", :controller => "users", :action => "tutorial"

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
   map.root :controller => "application"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

	#map.connect '*path', :controller => 'application', :action => 'redirect_to_default'
end

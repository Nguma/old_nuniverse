ActionController::Routing::Routes.draw do |map|
  map.resources :comments

  map.resources :posts, :has_many  => :comments

  map.resources :facts


 	map.resources :taggings
	map.resources :comments
	map.resources :tags
	
	map.resources :nuniverses do |n|
		n.resources :collections, :requirements => {:context_type => 'nuniverse'}
		n.resources :comments, :requirements => {:context_type => 'nuniverse'}
		n.resources :users, :requirements => {:context_type => 'nuniverse'}
	end
	
	map.resources :polycos
	map.confirm_connection "/confirm-connection/:id/with/:subject_id/:subject_type", :controller => "Polycos", :action => "update"
	map.resources :images
	map.resources :bookmarks
	map.resources :locations
	map.resources :collections
	map.new_collection_item "/collections/:collection_id/children/new", :controller => "Polycos", :action => "new"

	map.resources :videos
	map.signup '/signup', :controller => 'users', :action => 'new'
 	map.register '/register', :controller => 'users', :action => 'create'
	map.resources :users do |u|
		u.resources :collections, :requirements => {:context_type => 'user'}
		u.resources :comments, :requirements => {:context_type => 'user'}
		u.resources :users, :requirements => {:context_type => 'user'}
	end
	


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
	  		
				m.account '/account', :action => 'account'
	  		m.upgrade '/upgrade', :action => 'upgrade'
		
	  	end
	
	
	map.locate "/locate", :controller => "locations", :action => "find"
	
	map.create_tag "/create_tag", :controller => "tags", :action => "create"
	map.make_connection "/make_connection/from/:object_type/:object_id/to/:subject_type/:subject_id", :controller => "polycos", :action => "connect"
	map.disconnect "/disconnect/:id", :controller => "connections", :action => "disconnect"
	
	map.suggest "/suggest", :controller => "nuniverses", :action => "suggest"
	
	map.share_story "/share-this-nuniverse/:id", :controller => "stories", :action => "share"
	map.add_to_nuniverse "/add-to-favorites/:id", :controller => "connections", :action => "add_to_favorites"
	map.remove_from_nuniverse "/remove-comment/:id", :controller => "comments", :action => "destroy"
	map.preview "/preview/:id", :controller => "connections", :action => "preview"
	map.send_email "/send_email/:id", :controller => "tags", :action => "send_email"
	
	map.update_polyco "/polycos/:id/update", :controller => "polycos", :action => "update"
	
	map.create_box "/create-box", :controller => "boxes", :action => "create"
	map.save_layout "/save-layout", :controller => "application", :action => "save_layout"
	map.save_layout "/save-layout.:format", :controller => "application", :action => "save_layout"
	
	map.search "/search-for/:input.:format", :controller => "nuniverses", :action => "index"
	map.search "/search-for/:input", :controller => "nuniverses", :action => "index"
	map.search "/search-for", :controller => "nuniverses", :action => "index"
	map.search "/search", :controller => "nuniverses", :action => "index"
	
	map.tutorial "/tutorial", :controller => "users", :action => "tutorial"
	map.connect "/facts/create", :controller => "facts", :action => "create"

  map.root :controller => "application"

	map.save "/save/:namespace", :controller => "nuniverses", :action => "save"
	map.save "/save/:namespace.:format", :controller => "nuniverses", :action => "save"
	
	map.wdyto "/wdyto/:namespace", :controller => "nuniverses", :action => "wdyto"
	map.nuniverse "/nuniverse-of/:namespace", :controller => "users", :action => "show"
	map.nuniverse "/nuniverse-of/:namespace/:filter.:format", :controller => "users", :action => "show"
	
	map.add_tag "/add-tag", :controller => "tags", :action => "create"
	
	map.follow "/follow/:login", :controller => "users", :action => "follow"
	map.follow "/stop-following/:login", :controller => "users", :action => "stop_following"
		
	map.process "/rate/:namespace/:score", :controller => "rankings", :action => "create"
	map.process "/rate/:namespace/:score.:format", :controller => "rankings", :action => "create"
	map.comment "/comment/create", :controller => "comments", :action => "create"
	map.comment "/comments/create", :controller => "comments", :action => "create"
	map.comment "/comments/create.:format", :controller => "comments", :action => "create"
	
	map.connecting "/connect", :controller => "polycos", :action => "connect"
	
	map.process "/process", :controller => "polycos", :action => "create"
	map.connect "/sessions/create", :controller => "sessions", :action => "create"
	map.connect "/admin/:action/:id", :controller => "admin"
	map.connect "/locations/show/:id", :controller => "locations", :action => "show"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

	map.bestof '/best/:tag', :controller => "tags", :action => "show"


	# map.connect '*path', :controller => 'nuniverses', :action => 'show'


	#map.connect '*path', :controller => 'application', :action => 'redirect_to_default'
end

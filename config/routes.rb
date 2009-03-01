ActionController::Routing::Routes.draw do |map|
  map.resources :comments

  map.resources :posts, :has_many  => :comments

  map.resources :facts

  map.resources :stories

	map.resources :kinds
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
	  		m.home '/my_nuniverse', :action => 'show'
				m.account '/account', :action => 'account'
	  		m.upgrade '/upgrade', :action => 'upgrade'
		
	  	end
	
	map.locate "/locate", :controller => "locations", :action => "find"
	
	map.create_tag "/create_tag", :controller => "tags", :action => "create"
	map.make_connection "/make_connection/from/:object_type/:object_id/to/:subject_type/:subject_id", :controller => "polycos", :action => "connect"
	map.disconnect "/disconnect/:id", :controller => "connections", :action => "disconnect"
	
	map.suggest "/suggest-a-nuniverse", :controller => "nuniverses", :action => "suggest"
	
	map.share_story "/share-this-nuniverse/:id", :controller => "stories", :action => "share"
	map.add_to_nuniverse "/add-to-favorites/:id", :controller => "connections", :action => "add_to_favorites"
	map.remove_from_nuniverse "/remove-comment/:id", :controller => "comments", :action => "destroy"
	map.preview "/preview/:id", :controller => "connections", :action => "preview"
	map.send_email "/send_email/:id", :controller => "tags", :action => "send_email"
	
	map.update_polyco "/polycos/:id/update", :controller => "polycos", :action => "update"
	
	map.create_box "/create-box", :controller => "boxes", :action => "create"
	map.save_layout "/save-layout", :controller => "application", :action => "save_layout"
	map.save_layout "/save-layout.:format", :controller => "application", :action => "save_layout"
	map.find_nuniverse "/find-nuniverse", :controller => "nuniverses", :action => "index"
	map.find_nuniverse "/find-nuniverse/:input", :controller => "nuniverses", :action => "index"

	
	
	map.tutorial_url "/tutorial", :controller => "users", :action => "tutorial"
	
	map.visit "/visit/:user/:story", :controller => "stories", :action => "show"
	map.add_text_box "/add-text-box-to/:story", :controller => "boxes", :action => "add_text_box"
	map.add_image_box "/add-image-box-to/:story", :controller => "boxes", :action => "add_text_box"
	
	map.connections_for "/connections-for/:unique_name/tagged/:tag", :controller => "tags", :action => "show"
	map.videos_for "/videos-for/:unique_name", :controller => "videos", :action => "index"
	map.stories_for "/stories-for/:class/:id", :controller => "stories", :action => "index"

	map.create_nuniverse "/create-a-nuniverse", :controller => "stories", :action => "new"
	map.talk_about "/talk-about/:unique_name", :controller => "nuniverses", :action => "discuss"	
	
	map.nuniverse_by_name "/nuniverse-of/:unique_name", :controller => "nuniverses", :action => "show"
  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
   map.root :controller => "application"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

	#map.connect '*path', :controller => 'application', :action => 'redirect_to_default'
end

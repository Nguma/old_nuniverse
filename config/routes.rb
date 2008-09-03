ActionController::Routing::Routes.draw do |map|
  map.resources :rankings

  map.resources :lists

  map.resources :tags do |tag|
    tag.resource :avatar
  end
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
	
	map.upgrade "/upgrade",
		:controller => "users",
		:action => "upgrade"

	map.beta "/beta",
		:controller => "application",
		:action => "beta"

	map.feedback "/feedback",
		:controller => "application",
		:action => "feedback"

	map.feedback "/thank_you",
		:controller => "application",
		:action => "thank_you"
	
	map.my_nuniverse "/my_nuniverse",
		:controller => 'users',
		:action => 'show'
		
	map.my_people "/my_people/",
		:controller => "users",
		:action => "show",
		:kind => "person"

	map.my_people "/my_places/",
		:controller => "users",
		:action => "show",
		:kind => "location"
		
	map.with_kind "/display/:kind/of/:id",
		:controller => "taggings",
		:action => "show"
		
	map.restricted "/restricted",
		:controller => "application",
		:action => 'restricted'
		
	map.visit "/visit/:path",
		:controller => "taggings",
		:action => "show"
		
	map.bookmark "/bookmark/:path",
		:controller => "taggings",
		:action => "bookmark"
		
	map.videos "/rate/:id/:stars",
		:controller => "taggings",
		:action => "rate"
		
	map.details_for "/details_for/:source/:id",
		:controller => "ws",
		:action => "show"
		
	map.overview_for "/overview_for/:path",
		:controller => "nuniverse",
		:action => "overview"
	
	map.google "/google/:id",
		:controller => 'taggings',
		:action => "show",
		:service => "google"
					
	map.map "/map/:id",
		:controller => "taggings",
		:action => "show",
		:service => "map"
	
	map.suggest "/suggest",
		:controller => 'tags',
		:action => "suggest"
	
	map.connect "/connect",
		:controller => '/nuniverse',
		:action => 'connect'

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
   map.root :controller => "nuniverse"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

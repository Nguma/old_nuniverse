ActionController::Routing::Routes.draw do |map|
  map.resources :rankings

  map.resources :lists

  map.resources :tags do |tag|
    tag.resource :image
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

		
	map.tags "/about/:label",
		:controller => "tags",
		:action => "show"

		
	map.restricted "/restricted",
		:controller => "application",
		:action => 'restricted'
		
	map.suggest "/suggest",
		:controller => 'tags',
		:action => "suggest"
	
	map.connect "/connect",
		:controller => '/nuniverse',
		:action => 'connect'
	
	map.with_options :controller => 'application' do |m|
		m.thank_you '/thank_you', :action => 'thank_you' 
		m.feedback '/feedback', :action => 'feedback'
		m.beta '/beta', :action => 'beta'
	end
			
	map.with_options :controller => 'users' do |m|
		m.home '/my_nuniverse', :action => 'show'
		m.upgrade '/upgrade', :action => 'upgrade'
	end
	
	map.with_options :controller => 'lists' do |m|
		m.people '/my_nuniverse/people', :action => 'show', :label => 'people'
		m.places '/my_nuniverse/places', :action => 'show', :label => 'places'
		m.list '/my_nuniverse/:label/:page', :action => 'show', :requirements => {:page => /\d+/}, :page => nil
	end
		
	map.with_options :controller => 'taggings' do |m|
		m.google '/google/:id', :action => 'show', :service => 'google'
		m.rate '/rate/:id/:stars', :action => 'rate'
		m.map '/locate/:id', :action => 'show', :service => 'map'
		m.bookmark '/bookmark/:path', :action => 'bookmark'
	end
	
	map.command '/command', 
		:controller => 'nuniverse',
		:action => 'command'


  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
   map.root :controller => "nuniverse"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

ActionController::Routing::Routes.draw do |map|
  map.resources :tags do |tag|
    tag.resource :avatar
  end

	map.resource :user
	map.resources :sessions
	
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
	map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
	map.signup '/signup', :controller => 'users', :action => 'new'
	map.login '/login', :controller => 'sessions', :action => 'new'
	map.logout '/logout', :controller => 'sessions', :action => 'destroy'
	
	map.my_account "/my_account",
		:controller => 'users',
		:action => 'show'

	map.my_nuniverse "/my_nuniverse",
		:controller => 'users',
		:action => 'show'
	
	map.nuniverse_of "/nuniverse_of/:path",
		:controller => 'tags',
		:action => 'show'

	map.nuniverse_of_with_page "/nuniverse_of/:path/page/:page",
		:controller => 'tags',
		:action => 'show'
		
	map.nuniverse_of "/nuniverse_of/:id/:filter",
			:controller => 'tags',
			:action => 'show'
		
	map.nuniverse_of_with_path "/nuniverse_of/:id/with_path/:path",
		:controller => 'tags',
		:action => 'show'

	map.section_of "/section_of/:path",
		:controller => 'tags',
		:action => 'section'
					
	map.show_only "/nuniverse_of/:path/show_only/:filter",
		:controller => 'tags',
		:action => 'section'
		
	map.overview "/nuniverse_of/:path/overview/",
		:controller => 'tags',
		:action => 'section'
		
	map.nuniverse_of_according_to "/nuniverse_of/:path/according_to/:perspective",
		:controller => 'tags',
		:action => 'show'
		
	map.current_nuniverse_according_to "/current_nuniverse/according_to/:perspective",
		:controller => 'tags',
		:action => 'section'
		
	map.nuniverse "/nuniverse/:filter",
		:controller => "tags",
		:action => "index"
	
	map.bookmark "/bookmark/:path",
		:controller => "taggings",
		:action => "bookmark"
		
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
   map.root :controller => "taggings"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

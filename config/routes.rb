ActionController::Routing::Routes.draw do |map|
  map.resources :tags do |tag|
    tag.resource :avatar
  end

	map.resource  :user
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
		:controller => 'nuniverse',
		:action => 'show'

	map.nuniverse_of_with_section "/nuniverse_of/:path/section/:section",
		:controller => 'nuniverse',
		:action => 'show'

	map.section_of "/section_of/:path",
		:controller => 'nuniverse',
		:action => 'section'
					
	map.show_only "/nuniverse_of/:path/show_only/:filter",
		:controller => 'nuniverse',
		:action => 'section'
			
	map.according_to "/current_section/according_to/:perspective",
		:controller => 'nuniverse',
		:action => 'section'
		
	map.current_nuniverse_according_to "/current_nuniverse/according_to/:perspective",
		:controller => 'nuniverse',
		:action => 'section'
		
	map.nuniverse "/nuniverse/:filter",
		:controller => 'nuniverse',
		:action => "index"
	
	map.bookmark "/bookmark/:path",
		:controller => "taggings",
		:action => "bookmark"
		
	map.videos "/videos",
		:controller => "ws",
		:action => "videos"
		
	map.video "/video",
		:controller => "ws",
		:action => "video"
		
	map.details_for "/details_for/:source/:id",
		:controller => "ws",
		:action => "show"
		
	map.overview_for "/overview_for/:path",
		:controller => "nuniverse",
		:action => "overview"
	
	map.section "/section/:path",
		:controller => 'nuniverse',
		:action => "section"

	map.section_by "/section/:path/by/:order",
		:controller => 'nuniverse',
		:action => "section"
		
	map.current_section_by "/current_section/by/:order",
		:controller => 'nuniverse',
		:action => "section"

	map.section_by"/section/:path/with_kind/:kind/by/:order",
		:controller => 'nuniverse',
		:action => "section"
		
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

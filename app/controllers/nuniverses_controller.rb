class NuniversesController < ApplicationController
	
	before_filter :find_user, :only => [:suggest, :show, :command]
	before_filter :update_session, :only => [:show]
 	after_filter :store_location, :only => [:show]

	def index
		@nuniverses = Nuniverse.paginate(:page => params[:page], :per_page => 20)
	end
	
	def show
		@nuniverse = Nuniverse.find(params[:id])
		@perspective = params[:perspective]
	
		@source = @nuniverse
	
		@connections = @nuniverse.connections.of_klass(@klass)
		case params[:order]
		when "by_latest"
			@connections = @connections.order_by_date
		when "by_name"
			@connections = @connections.order_by_name
		else
			@connections = @connections.order_by_score(@perspective)
		end
		
		@connections = @connections.with_score.paginate(:per_page => 20, :page => params[:page])
		
	end
	
end

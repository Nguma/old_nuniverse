class NuniverseController < ApplicationController
	
	before_filter :find_user, :only => [:suggest, :show, :command]
	
	def index
		redirect_to "/my_nuniverse" if logged_in?
	end
	
	def show
		@nuniverse = Nuniverse.find(params[:id])
		raise @nuniverse.connections.inspect
	end
	
end

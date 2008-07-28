class WsController < ApplicationController
	
	def show
		@service = params[:service]
		@id = params[:item]
		@flashvars = params[:flashvars] || ""
		render :layout => false
	end
	
end
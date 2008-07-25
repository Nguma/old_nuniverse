class WsController < ApplicationController
	
	def show
		@service = params[:service]
		@id = params[:item]
		render :layout => false
	end
	
end
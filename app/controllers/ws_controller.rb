class WsController < ApplicationController
	
	def show
		@service = params[:service]
		@id = params[:item]
		@flashvars = params[:flashvars] || ""
		@path = TaggingPath.new session[:path]
		render :layout => false
	end
	
	def find
		@results = Finder::Search.find(:query => params[:query], :service => params[:service])
		
		render :layout => false
	end
	
end
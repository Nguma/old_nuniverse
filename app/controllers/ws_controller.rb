class WsController < ApplicationController
	
	def show
		@service = params[:service]
		@id = params[:item]
		@flashvars = params[:flashvars] || ""
		@path = TaggingPath.new session[:path]
		render :layout => false
	end
	
	def find
		@tagging = Tagging.find(params[:id])
		
		render :co => false
	end
	
end
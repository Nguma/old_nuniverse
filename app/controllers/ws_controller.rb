class WsController < ApplicationController
	
	def show
		@service = params[:service]
		@id = params[:item]
	end
	
	def video
		@ws_url = params[:url]
		@flashvars = params[:flashvars] || ""
		respond_to do |format|
      format.html { render :action => :show, :layout => false }
      format.xml  { head :ok }
    end
	end
	
end
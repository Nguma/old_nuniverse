class WsController < ApplicationController
	
	def show
		@details = details(:source => @source, :id => @id)
	end
	
	def video
		@ws_url = params[:url]
		respond_to do |format|
      format.html { render :action => :show, :layout => false }
      format.xml  { head :ok }
    end
	end
	
end
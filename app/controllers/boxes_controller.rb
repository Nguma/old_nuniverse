class BoxesController < ApplicationController

	def create
		
		@box = Box.create(params[:box])
		@box.width = params[:w]
		@box.height = params[:h]
		@box.x = params[:x]
		@box.y = params[:y]
		@box.save 
		respond_to do |f|
			
			f.js {head :ok}
		end
	end
	
	

end
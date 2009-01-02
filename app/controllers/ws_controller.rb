class WsController < ApplicationController

	
	def find
		@tagging = Tagging.find(params[:id])
		
		render :co => false
	end
	
	def suggest_address 
			@tag = Tag.find(params[:id])
			@input = params[:input] || @tag
			
			respond_to do |f|
				f.html {}
				f.js { }
			end
			
	end
	
end
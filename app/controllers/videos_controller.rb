class VideosController < ApplicationController

	def index
		@token.category = "video"
		@videos = @token.namespace.videos.paginate(:page => 1, :per_page => 10)
		respond_to do |f|
			f.html{}
			f.js  {}
		end
	end
	
	def show
		@tag = Tag.find_by_name(q[0])
		@video = @tag
		# @url = params[:url]
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
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
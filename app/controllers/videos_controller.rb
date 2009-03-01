class VideosController < ApplicationController

	def index
		@source = Nuniverse.find_by_unique_name(params[:unique_name])
	
		@videos = @source.videos.paginate(:page => 1, :per_page => 10)
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
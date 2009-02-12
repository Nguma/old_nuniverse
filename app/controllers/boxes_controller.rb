class BoxesController < ApplicationController

	def create
		
		@box = Box.create(params[:box])
		respond_to do |f|
			
			f.js {head :ok}
		end
	end
	
	
	def update
		@box = Box.find(params[:id])
		@box.update_attributes(params[:obj])
		respond_to do |f|
			f.html {}
			f.js {head :ok}
		end
	end
	
	
	def edit
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def live
		@box = Box.find(params[:id])
		@selection = params[:source][:type].classify.constantize.find(params[:source][:id])
		
	end

	def show
		
	end
	
	def add_text_box
		@story = Story.find(params[:story])
		@box = Box.new(:width => 300, :height => 100, :x => 300, :y => 200, :mode => "text")
		@box.parent = @story
	end
end
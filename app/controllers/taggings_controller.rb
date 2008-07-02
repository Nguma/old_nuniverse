class TaggingsController < ApplicationController
	
	
	def index
		@connections = Tagging.find(:all, :order => "created_at DESC")
	end

end

class TaggingsController < ApplicationController
	
	
	def index
		@connections = Tagging.find(:all, :order => "created_at DESC")
	end
	
	def create
		
		@tagging = Tag.connect(
			:content 	=> params[:content],
			:kind			=> params[:kind],
			:path			=> params[:path],
			:restricted => params[:restricted],
			:description => params[:description],
			:user_id	=> current_user.id
		)
		
    respond_to do |format|
        flash[:notice] = 'Connection was successfully created.'
        format.html { render :action => "add" }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag  }
    end
	end
end

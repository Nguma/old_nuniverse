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
        format.html { render :layout => false }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag  }
    end
	end
	
	def move
		t = Tagging.find_by_id(248)
		t.move("30_226", "30_232_226")
	end

end

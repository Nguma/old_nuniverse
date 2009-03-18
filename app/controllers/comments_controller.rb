class CommentsController < ApplicationController
	
	before_filter :find_source, :only => [:index]
	
	def index
	
		@comments = @context.comments.paginate(:page => 1, :per_page => 5, :order => "created_at DESC")
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def create

		@comment = Comment.create(params[:value], :user_id => current_user.id)
		
		respond_to do |f|
			f.html { redirect_to @post }
			f.js { 
				@nuniverse = @comment.parent
				@comments = @nuniverse.comments.paginate(:page => 1, :per_page => 5, :order => "created_at DESC") 
				render :action => :index
			}
		end
	end
end

class CommentsController < ApplicationController
	
	before_filter :find_context, :only => [:index]
	
	def index
	
		@comments = @context.comments.paginate(:page => 1, :per_page => 5, :order => "created_at DESC")
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def create
		# @parent =  params[:parent_type].classify.constantize.find(params[:parent_id])
		@comment = Comment.create(params[:comment])
		# @comment = @post.comments.build(params[:comment])
		# @comment.author = current_user
		# @comment.save!
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

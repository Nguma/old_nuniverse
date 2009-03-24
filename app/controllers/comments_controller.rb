class CommentsController < ApplicationController

	before_filter :find_source, :only => [:create]
	
	def index
		@comments = @context.comments.paginate(:page => 1, :per_page => 5, :order => "created_at DESC")
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def create
		@command = Command.new(params[:command])
		@comment = Comment.create(:body => @command.value, :user_id => current_user.id, :parent_id => @source.id, :parent_type => @source.class.to_s)
		@source.comments << @comment
		@polyco = @source.connections.with_subject(@comment).first
		@polyco.tags << @command.tag if @command.order != 'comment'
		
		respond_to do |f|
			f.html { redirect_to @source }
		
			f.js { 
			
			}
		end
	end
end

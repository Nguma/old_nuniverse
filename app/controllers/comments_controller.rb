class CommentsController < ApplicationController
	
	before_filter :find_user
	before_filter :find_comment, :only => [:show]
	
	def create
		@comment = Comment.create(params[:comment])
		Polyco.create(:subject => @comment, :object_id => params[:object][:id], :object_type => params[:object][:type]) if params[:object]
		respond_to do |f|
			f.html { redirect_back_or_default('/')}
			f.js {}
		end
	end
	
	def new
		@subject = Tag.find(params[:subject]) 
		@kind = params[:kind] || "note"
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end

	
	def show
		
	end
	
	protected
	def find_comment
		@comment = Comment.find(params[:id])
	end
end

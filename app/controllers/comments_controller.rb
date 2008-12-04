class CommentsController < ApplicationController
	
	before_filter :find_user
	
	def create
		@tag = Tag.find(params[:tag_id])
		@comment = Comment.create(
			:user => current_user,
			:body => params[:body],
			:kind => params[:kind])
		@comment.tag.connect_with(@tag, :as => params[:kind], :user => current_user)
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def find_comment
		@comment = Comment.find(params[:id])
	end
end

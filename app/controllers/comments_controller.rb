class CommentsController < ApplicationController
	
	before_filter :find_user
	
	def create
		@object = Tag.find(params[:subject]) rescue Tag.find(params[:object])
		@kind = params[:kind] || "note"
		
		@comment = Comment.create!(
			:user => current_user,
			:body => params[:body])

		@comment.tag_with('note')
		@c = @comment.tag.connect_with(@object, :as => @kind, :user => current_user)
	
	
		respond_to do |f|
			f.html {}
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
	
	def find_comment
		@comment = Comment.find(params[:id])
	end
end

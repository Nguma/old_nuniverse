class CommentsController < ApplicationController
	
	before_filter :find_user
	
	def create
		@object = Tag.find(params[:object])
		
		@comment = Comment.create!(
			:user => current_user,
			:body => params[:body])
			
		@comment.tag_with('note')
		# @comment.tag.connect_with(@object, :as => 'note', :user => current_user)
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def new
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def find_comment
		@comment = Comment.find(params[:id])
	end
end

class GroupsController < ApplicationController

	before_filter :find_user, :find_everyone
	
	def index
		# Adds default perspectives that aren't stored in db (Self, Everyone)
		@perspectives = [current_user.perspectives, @everyone.perspectives].flatten

		@sections = @perspectives.group_by {|c| c.kind}
	end
	
	def update
		selected_favs = params[:favorite_ids].split(',')
		@favorites  = Perspective.find(:all, :conditions => ['(id in (?) AND user_id != 0) OR (user_id = ? AND favorite = 1)', selected_favs, current_user.id])
		@favorites.each do |fav|
			if selected_favs.include?(fav.id.to_s)
				fav.favorite = 1
			else
				fav.favorite = 0
			end
			fav.save
		end
		redirect_to('/groups')
	end
	
	def suggest
		
		@groups = Group.find(:all, :conditions => ['name rlike ?', "^#{params[:input]}"])
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def select
	end
	
	def create

		@group = Group.create(
			:name => params[:input],
			:user => current_user
		 )
		
		current_user.tag.connect_with(@group.tag, :user => current_user, :as => "founder")
		respond_to do |f|
			f.html {}
			f.js {}
		end
		
	end
	
	def update
		@group = Group.find(params[:id])
		
		@group.private = params[:private] if params[:private]
		if params[:member]
			
			user = User.find(params[:member])
	
			user.tag.connect_with(@group.tag, :user => current_user, :as => 'member')
		end
		
		respond_to do |f|
			f.html {}
			f.js { render :action => "create"}
		end
	end
	
	def join
		@group = Group.find(params[:id])
		if @group.private
			# UserMailer.deliver_group_request(:from => current_user, :group => @group)
			current_user.tag.connect_with(@group.tag, :user => @group.user, :as => "pending")
		else
			current_user.tag.connect_with(@group.tag, :user => current_user, :as => "member")
		end
		
		respond_to do |f|
			f.html {}
			f.js { }
		end
			
	end
	
	def new
	end
	
	def delete
		@group = Group.find(params[:id])

		@group.destroy
		redirect_back_or_default "/admin/groups"
	end
	
	def preview
		@group = Group.find(:first, :conditions => ['tag_id = ? ', params[:id]])
		@founder = Connection.with_subject(@group.tag).with_kind("user").tagged("founder").first.object
	
		@members = Connection.with_subject(@group.tag).with_kind("user").tagged("member").paginate(:page =>1, :per_page => 10)
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
end

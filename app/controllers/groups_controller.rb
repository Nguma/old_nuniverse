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
		
		@input = params[:input]
		@kind = params[:kind]
		case @kind
			
		when "user"
			@users =	User.find(:all, :conditions => ['(login rlike ? OR email = ?) AND role != "service"', "^#{params[:input]}",params[:input]], :limit => 3)
			render :action => "suggest_users", :layout => false
		else
			@tags = Tag.with_label(params[:input]).with_kind(params[:kind]).paginate(:page => 1, :per_page => 3)
			render :action => "suggest_groups", :layout => false
		end	
		
	end
	
	def select
	end
	
	def create
		@group = Group.create(
			:name => params[:input],
			:user => current_user
		 )
		
	end
end

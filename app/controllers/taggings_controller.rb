class TaggingsController < ApplicationController
	protect_from_forgery :except => [:create]
	#include SMSFu
	
	before_filter :login_required, :except => [:preview, :suggest]
	before_filter :find_tagging, :except => [:index]
	skip_before_filter :invitation_required, :only => [:suggest]
	after_filter :store_location, :only => [:show]

	def index
		redirect_to "/my_nuniverse"
	end
	
	def edit
		@items = @tagging.connections.paginate(:page => params[:page] || 1, :per_page => 10)
	end
	
	def update
		restrict_to([@tagging.owner])
		
		@tagging.update_with(params)
		redirect_to @tagging
	end
	
	def destroy
		raise "You don't have the right to do this!" if current_user != @tagging.owner
		@tagging.destroy
		if @parent 
			redirect_back_or_default("/taggings/#{@parent}")
		else
			redirect_back_or_default("/my_nuniverse")
		end
		
	end
	
	def show

	
	end
	
	def share
		@contributors = @tagging.contributors(:page => params[:page] || 1, :per_page => 10)
	end
	
	def invite
		@user = User.find_by_email(params[:email]) || User.create(:email => params[:email])
		current_user.invite(:user => @user, :topic => @tagging)
		redirect_back_or_default("/taggings/share/#{@tagging.id}")
	end

	
	def preview
		@items = @tagging.connections.paginate(:page => 1, :per_page => 5)
	end
	
	def bookmark
		@tag = Tag.find(:first, :conditions => ['url = ?', params[:url]])
		
		@tag = Tag.create(
			:name => params[:name],
			:kind => params[:kind],
			:url => params[:url],
			:service =>params[:service],
			:data => params[:data],
			:description => params[:description] ) if @tag.nil?
			
		Tagging.create(
			:object => @tag,
			:subject => @tagging.object,
			:owner => current_user,
			:kind => params[:kind])
			
		respond_to do |format|
			format.html {redirect_back_or_default @tagging, :service => params[:service] || nil	}
			format.js { head :ok}
		end
		
		
	end
	
	def find_or_create
		if params[:id]
			@tagging = Tagging.find(params[:id])
			@tagging = @tagging.clone
				@tagging.user_id = current_user.id
				@tagging.kind = params[:kind]
				@tagging.save
		else
		end
	
		
		redirect_back_or_default("/")
	end
	
	def rate
		@ranking = Ranking.find_or_create(:tagging => @tagging, :user => current_user)
		@ranking.value += 1
		@ranking.save
		redirect_to :back
		# respond_to do |format|
		# 		format.html {render :layout => false}
		# 		format.js { render :layout => false}
		# 	end
	end
	
	def sms
		@items = @tagging.connections.paginate(:page => @page, :per_page => 10)
		
	end
	
	def suggest
		@kind = params[:kind]
		@taggings = Tagging.select(
		:users => [current_user],
		:current_user => current_user,
		:name => params[:name],
		:perspective => "everyone")
	end
	
	def new
		@form = params[:form]
		@tags = params[:category].to_a rescue []
		
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	protected
	
	def find_tagging	
		@tagging = Tagging.find(params[:id]) rescue nil
	end
	
	
end
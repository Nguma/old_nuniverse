class AdminController < ApplicationController
	skip_before_filter :invitation_required
	before_filter :admin_required
	
	def index
	end
	
	def users
		@users = User.find(:all).paginate(:page => params[:page] || 1, :per_page => 10)
	end
	
	def send_activation_code
		@user = User.find(params[:id])
		UserMailer.deliver_activation_code(@user)
		redirect_to "/admin/users"
	end
	
	def permissions
		@page = params[:page] || 1
		@permissions = Permission.find(:all).paginate(:page => @page, :per_page => 10)
		
	end
end

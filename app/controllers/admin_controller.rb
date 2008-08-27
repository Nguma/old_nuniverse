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
	end
end

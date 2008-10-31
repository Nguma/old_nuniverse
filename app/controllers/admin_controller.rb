class AdminController < ApplicationController
	skip_before_filter :invitation_required
	before_filter :admin_required
	
	def index
	end
	
	def users
		@users = User.find(:all).paginate(:page => params[:page] || 1, :per_page => 20)
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
	
	def ct 
		cts = [

		]
		cts.each_with_index do |ct,i|
			
				
				t = Tag.new(:label => ct[0], :kind => 'restaurant', :data => "#country US #city NYC #menupages_id #{ct[1]} ")
				t.save
				Tagging.create(:subject_id => 0, :object_id => t.id, :user_id => 0, :kind => 'japanese restaurant', :public => 1)

		end
	end
	
	def batch

		if params[:batch]
			@batch = params[:batch].split("--")
			@batch.each do |item|
				t = Tag.new(:label => item, :kind => params[:kind])
				t.save
				Tagging.create(:subject_id => 0, :object_id => t.id, :user_id => 0, :kind => t.kind, :public => 1)
			end	
			@batch = ""
			flash[:notice] = "batch is a done deal."
		end
		
	end
	
	def test
		@url = params[:url]
	end
end

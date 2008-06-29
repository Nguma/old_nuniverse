class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
	before_filter :login_required, :only => [:index]

	# GET /index
	# GET /my_account
	def index
		@user = self.current_user
		
		respond_to do |format|
			format.html #index.html.erb
		end
	end
	
  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.make(params[:user])
		
		   
    if @user.errors.empty?
      self.current_user = @user
      redirect_back_or_default("/my_account")
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end


	protected
	def destroy
		@user = User.find(params[:id])
		@user.destroy
		
		redirect_to '/'
	end

end

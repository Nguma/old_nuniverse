class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
	before_filter :login_required, :except => [:new, :create]

	# GET /user
	# GET /my_account
	def show
		@user = self.current_user
	end
	
  # render new.rhtml
  def new
    #
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
		   
    if @user.valid? # errors.empty?
      @user.save
      self.current_user = @user
      
      redirect_back_or_default("/my_account")
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end
  
  def edit
    @user = self.current_user
  end
  
  def update
    @user = self.current_user
    
    if @user.update_attributes(params[:user])
      redirect_to user_path
    else
      render :action => "edit"
    end
  end

  protected
	
	def destroy
		@user = User.find(params[:id])
		@user.destroy
		
		redirect_to '/'
	end

end

# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # GET /new
  def new
		respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(self.current_user.tag)
      flash[:notice] = "Logged in successfully"
    else
      redirect_to '/login'
			flash[:notice] = "Wrong username / password "
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

	def select(tag)
		self.contexts.reject {|c| c == self.selected.id}
		self.selected = tag
	end
	
	def make_history(contexts)
		self.contexts = contexts
	end
end

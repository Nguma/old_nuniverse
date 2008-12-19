class UsersController < ApplicationController
  
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:show, :suspend, :unsuspend, :destroy, :purge]
	before_filter :login_required, :except => [:new, :activate, :create]
	skip_before_filter :invitation_required, :only => [:new, :create, :activate]
  after_filter :store_location, :only => [:show]
	after_filter :update_session, :only => [:show]
	
	def find
		@users = User.find(:all, :conditions => ['login rlike ? OR email rlike ?', "^#{params[:input]}{0,6}", "^#{params[:input]}{0,6}"])
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])

    success = @user && @user.valid?
    if success && @user.errors.empty?
			@user.register!
      redirect_to('/thank_you')
     # flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "There were some problems with creating the account. :("
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?

    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:notice] = "The activation code was missing."
    else 
      flash[:notice]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_to '/login'
    end
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end
	
	def suggest
		@users = User.find(:all, :conditions => ['login rlike ?', "^#{params[:input]}"])
		@suggestion_uri = params[:url] 
	
		respond_to do |f|
				f.html {}
				f.js {}
		end
	end

	def upgrade
	end
	
	def edit
		@user = current_user
	end
	
	def update
		@user = current_user
		@user.tag.replace_property('address',params[:user]['address']) if params[:user]['address']
		@user.tag.save
		redirect_to "/my_nuniverse"
	end
	
	def membership
		respond_to do |f| 
			f.html {}
			f.js {}
		end
	end
	
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

	# GET /user
	# GET /my_nuniverse
	def show
		@user ||= current_user
		redirect_to @user.tag 
		if @user && current_user != @user
				
		else
			@service = nil	
		end

		
		
		@mode = params[:mode] || (session[:mode] ? session[:mode] : 'card')
		@kind = params[:kind] || (session[:kind] ? session[:kind] : 'nuniverse')
		@order = params[:order] || (session[:order] ? session[:order] : 'by_latest')
		
		@tag = current_user.tag
		@perspective = current_user.tag
			
		@source = current_user.tag
		@input = params[:input]
		@items = Connection.with_object(@tag).with_subject_kind(@kind).tagged_or_named(params[:input]).order_by(@order).paginate(:per_page => 15, :page => params[:page] || 1)

		respond_to do |format|
			format.html {
				update_session

				@title = "#{current_user.login}'s nuniverse"
				@categories = Connection.with_object(@tag).with_subject_kind(@kind).gather_tags.paginate(:page => @page, :per_page => 200)
			
			}	
			format.js { 
				
			}
		end
	end
	
protected
  def find_user
    @user = User.find(params[:id]) rescue nil
  end
end

class UsersController < ApplicationController
  
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:show, :suspend, :unsuspend, :destroy, :purge, :upgrade]
	before_filter :login_required, :except => [:new, :activate, :create]
	skip_before_filter :invitation_required, :only => [:new, :create, :activate]
  after_filter :store_location, :only => [:show]
	before_filter :update_session, :only => [:show, :tutorial]
	
	def index
		# @users = User.paginate(:conditions => {:state => 'active'}, :page => 1, :per_page => 5)
		@users = []
		render :action => :find
	end
	
	def find
		@source = current_user
		@users = User.search params[:name], :conditions => {:state => 'active'}
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
		@source = current_user
	end
	
	def edit
		@user = current_user
	end
	
	def update
		@user = current_user

		if params[:user]['address']
		end
		@user.firstname = params[:user][:firstname]
		@user.lastname = params[:user][:lastname]
		if params[:image]
			begin
				@user.images << Image.create(params[:image]) 
			rescue
				
			end
		end
		@user.save
		
		redirect_to "/my_nuniverse"
	end
	
	def account
		@source =  current_user
		@count = @source.connections.count || 0
	end
	
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

	# GET /user
	# GET /my_nuniverse
	def show
		@user ||= current_user
		
		@source = @user
		
		@connections = @user.connections.of_klass(@klass)
		@count = @user.connections.count
		@filter = params[:filter] || ""
		
		render :action => :tutorial if @user == current_user && @count == 0
		case params[:order]
				when "by_latest"
					@connections = @connections.order_by_date
				when "by_name"
					@connections = @connections.order_by_name
				else
					@connections = @connections.order_by_score(@perspective)
				end
	
		@connections = @connections.with_score.sphinx(@filter, :page => 1, :per_page => 3000).paginate(:page => params[:page] || 1)
		
	
		
		respond_to do |format|
			format.html {
				@latest_stories = @user.connections.of_klass('Story').order_by_date.paginate(:page => 1, :per_page => 5)
		
			}	
			format.js { 
				
			}
		end
	end
	
	def tutorial
		@user = @source = current_user
	end
	
protected
  def find_user
    @source = @user = User.find(params[:id]) rescue nil
  end
end

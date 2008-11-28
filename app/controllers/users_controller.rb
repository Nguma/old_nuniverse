class UsersController < ApplicationController
  
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:show, :suspend, :unsuspend, :destroy, :purge]
	before_filter :login_required, :except => [:new, :activate, :create]
	skip_before_filter :invitation_required, :only => [:new, :create, :activate]
  after_filter :store_location, :only => [:show]
	after_filter :update_session, :only => [:show]

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.register! if @user && @user.valid?
    success = @user && @user.valid?
    if success && @user.errors.empty?
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
	
  
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

	# GET /user
	# GET /my_nuniverse
	def show
		if @user && current_user != @user
			redirect_to @user.tag 	
		else
			@service = nil	
		end

		@user = current_user
		
		@mode = params[:mode] || (session[:mode] ? session[:mode] : 'card')
		@tag = current_user.tag
		@perspective = current_user.self_perspective
		@order = params[:order] || "rank"
		@kind = params[:kind] || nil
		@title = "#{current_user.login}'s nuniverse"
		@source = current_user.tag
		@input = params[:input]
		@items = current_user.connections(:label => @input, :per_page => 16, :page => params[:page] || 1)
		
		
		respond_to do |format|
			format.html {
				update_session
				@categories = Tagging.paginate_by_sql(
				"SELECT TA.kind as name,  count(DISTINCT TA.object_id) AS counted FROM taggings TA WHERE TA.user_id = #{current_user.tag.id} GROUP BY TA.kind ORDER BY TA.kind ASC",
				:page => 1,
				:per_page => 50)
			}	
			format.js { 
				render :controller => 'user', :action => :page, :layout => false
			}
		end
	end
	
protected
  def find_user
    @user = User.find(params[:id]) rescue nil
  end
end

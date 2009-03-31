class UsersController < ApplicationController
  
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:show, :suspend, :unsuspend, :destroy, :purge, :upgrade]
	before_filter :login_required, :except => [:new, :activate, :create]
	skip_before_filter :invitation_required, :only => [:new, :create, :activate]
  after_filter :store_location, :store_source, :only => [:show]
	before_filter :update_session, :only => [:show, :tutorial]
	
	def index
		# @users = User.paginate(:conditions => {:state => 'active'}, :page => 1, :per_page => 5)
		@nuniverse = Nuniverse.find(params[:nuniverse_id])
		
		@users = @nuniverse.users
	
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
      return nil
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
		respond_to do |f|
			f.html {}
			f.js {}
		end
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
		@tag = Tag.find_by_name(params[:filter]) || nil
		@source = User.find_by_login(params[:namespace])
		@votes = @source.votes.paginate(:page => params[:page], :per_page => 20, :order => :created_at)
		@reviews = Comment.search(:with => {:user_id => [@source.tastemakers, @source].flatten.collect {|c| c.id} }, :page => params[:page], :per_page => 10, :order => "created_at DESC")
		# @saved_items = @source.nuniverses.tagged(@tag).paginate(:page => params[:page], :per_page => 20)
		conditions = {:from_user => true, :to_nuniverse => true, :object_id => current_user.id}
		
		conditions[:tag_ids] = @tag.id  unless @tag.nil?

		@saved_items = Polyco.search(:with => conditions, :page => params[:page], :per_page => 20, :order => :created_at, :sort_mode => :desc)
		@tags = Tag.search(:with => {:related_user_ids => current_user.id}, :order => :name, :page => params[:tag_page], :per_page => 30 )
		respond_to do |format|
			format.html { }	
			format.js {}
			format.json {

				render :json => {'tastebook' => @saved_items.collect {|item| item.subject.to_json } }
			}
		end
	end
	
	def tutorial
		@user = @source = current_user
	end
	
	def follow
		@user = User.find_by_login(params[:login])
		current_user.tastemakers << @user
		respond_to do |f|
			f.html { redirect_to "/nuniverse-of/#{@user.login}"}
			f.js { head :ok}
			f.json {}
		end
	end
	
	def stop_following
		@user = User.find_by_login(params[:login])
		current_user.tastemakers.delete @user
		respond_to do |f|
			f.html { redirect_to "/nuniverse-of/#{@user.login}"}
			f.js { head :ok}
			f.json {}
		end
	end
	
protected
  def find_user
     @user = User.find(params[:id]) rescue current_user
  end
end

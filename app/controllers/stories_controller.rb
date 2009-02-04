class StoriesController < ApplicationController
	
	before_filter :find_story, :except => [:new, :create, :index]
	before_filter :find_source, :only => [:index]
	# before_filter :find_context, :except => [:index]
	after_filter :store_location, :store_source,  :only => [:show]
	before_filter :update_session, :only => [:show]
	
	
  # GET /stories
  # GET /stories.xml
  def index

		@input = params[:input] 
		@source = params[:class].classify.constantize.find(params[:id]) rescue  nil
		if @source
			@stories = @source.stories.paginate(:page => 1, :per_page => 10)
		else
			@stories = Story.search(@input, :page => params[:page] || 1, :per_page => 10)
		end
		
    respond_to do |format|
      format.html # index.html.erb
			format.js {}
      format.xml  { render :xml => @stories }
    end
  end


  # GET /stories/1
  # GET /stories/1.xml
  def show
		
		
		
		# @comments = @story.comments.paginate(:page => params[:page], :per_page => 10, :order => "updated_at DESC")
		 @nuniverses = @story.nuniverses.paginate(:page => params[:page], :per_page => 10, :order => "updated_at DESC")
		# @contributors = @story.contributors.paginate(:page => params[:page], :per_page => 10, :order => "name DESC")
		
    respond_to do |format|
      format.html { 		@source = @story }
			format.js {}
      format.xml  { render :xml => @story }
    end
  end

  # GET /stories/new
  # GET /stories/new.xml
  def new
    @story = Story.new(:author => current_user)

    respond_to do |format|
      format.html # new.html.erb
			format.js {}
      format.xml  { render :xml => @story }
    end
  end

  # GET /stories/1/edit
  def edit
   	@suggestions = Nuniverse.search @story.name, :match_mode => :extended, :per_page => 5
  end

  # POST /stories
  # POST /stories.xml
  def create
		params[:active] = 1
		@story = Story.new(params[:story])
		@subject = params[:source][:type].classify.constantize.find(params[:source][:id]) rescue  nil
		@story.unique_name = Nuniversal.sanatize(@story.name)

    respond_to do |format|
      if @story.save
				@story.connections << Polyco.new(:subject => @story, :object =>@subject , :state => "active") if @subject
   			@story.author.stories << @story
        # flash[:notice] = 'Story was successfully created.'
        format.html { redirect_to polymorphic_url(@story) }
        format.xml  { render :xml => @story, :status => :created, :location => @story }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @story.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stories/1
  # PUT /stories/1.xml
  def update
   
		@story.state = "activated"

    respond_to do |format|
      if @story.update_attributes(params[:story])
	
        flash[:notice] = 'Story was successfully updated.'
        format.html { redirect_to(@story) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @story.errors, :status => :unprocessable_entity }
      end
    end
  end

	def add_item
		@item = Nuniverse.find(params[:subject][:id]) rescue Nuniverse.create(params[:subject])
	
		if @item.is_a?(Tag)
			@story.pending_items << @item rescue nil
		else
			@story.nuniverses << @item rescue nil
		end
		@context.nuniverses << @item rescue nil if @context 
		redirect_back_or_default('/')
	end
	

	
	def send_email
			@mail = UserMailer.deliver_story(
				:sender => current_user,
				:emails => params[:email][:emails],
				:story => @story,
				:message => params[:email][:message])
				
				 if @mail
		        flash[:notice] = "A mail was sent to #{params[:email][:emails]}" 
		      else
						flash[:notice] = "A mail was sent to #{params[:email][:emails]}"
		      end
				respond_to do |format|
		     
					format.html { redirect_to(@story) }
					
		    end
	end
	
	def connect
		@subject = Nuniverse.find(params[:nuniverse_id]) rescue Nuniverse.new(:name => @story.name)
		@story.nuniverses << @subject
		@story.state = "object"
		@story.save
		redirect_back_or_default("/")
	end
	
	def suggest
		
		@suggestions = Nuniverse.search(params[:subject][:name]).paginate(:page => 1, :per_page => 5)
	end
	
	def share
		# emails = params[:emails].split(/\,|\;/)
		# 		@users = []
		# 		emails.each do |email|
		# 			@users << User.find(:first, :conditions => ['email = ? OR login = ?', email, email])
		# 		end
		# 		
		# 		@story.contributors << @users
		respond_to do |format|
			format.html { redirect_back_or_default("/")}
			format.js {}
			format.js {}
		end
	end

  # DELETE /stories/1
  # DELETE /stories/1.xml
  def destroy
    
    @story.destroy

    respond_to do |format|
      format.html { redirect_to(stories_url) }
			format.js {head :ok}
      format.xml  { head :ok }
    end
  end

	protected
		
	def find_story
		if params[:id]
			@story = Story.find(params[:id])
		elsif params[:story] && params[:user]
			@story = Story.find(:first, :conditions => ["unique_name = ? and users.login = ?", params[:story], params[:user]], :include => :author)
		end
	end
	

	
end

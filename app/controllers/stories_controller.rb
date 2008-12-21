class StoriesController < ApplicationController
	
	before_filter :find_story, :except => [:new, :create, :index]
	after_filter :store_location, :only => [:show]
  # GET /stories
  # GET /stories.xml
  def index
    @stories = Story.created_by(current_user).without_parent.order_by_score
		

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stories }
    end
  end

  # GET /stories/1
  # GET /stories/1.xml
  def show
	
		@source = @story
		
		@connections = @source.connections
		
		case params[:order]
		when "by_latest"
			@connections = @connections.order_by_date
		when "by_name"
			@connections = @connections.order_by_name
		else
			@connections = @connections.order_by_score(@perspective)
		end
		
		@connections = @connections.with_score.paginate(:per_page => 20, :page => params[:page])
		

    respond_to do |format|
      format.html { }
      format.xml  { render :xml => @story }
    end
  end

  # GET /stories/new
  # GET /stories/new.xml
  def new
    @story = Story.new(:author => current_user)

    respond_to do |format|
      format.html # new.html.erb
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
    @story = Story.new(params[:story])

    respond_to do |format|
      if @story.save
        # flash[:notice] = 'Story was successfully created.'
        format.html { redirect_to(@story.parent) rescue redirect_to @story }
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
		@story.pending_items << Tag.new(params[:tag])
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

  # DELETE /stories/1
  # DELETE /stories/1.xml
  def destroy
    
    @story.destroy

    respond_to do |format|
      format.html { redirect_to(stories_url) }
      format.xml  { head :ok }
    end
  end

	protected
		
	def find_story
		@story = Story.find(params[:id])
	end
	
end

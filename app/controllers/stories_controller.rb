class StoriesController < ApplicationController
	
	before_filter :find_story, :except => [:new, :create, :index]
	before_filter :find_context, :except => [:index]
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
		@klass = 'nuniverse'

			@connections = @source.connections.with_score

		
		case params[:order]
		when "by_latest"
			@connections = @connections.order_by_date
		when "by_name"
			@connections = @connections.order_by_name
		else
			@connections = @connections.order_by_score(@perspective)
		end
		
		@connections = @connections.sphinx(nil, :conditions => {:context_ids => @context.id}, :per_page => 2000) if @context
		@connections = @connections.paginate(:per_page => 20, :page => params[:page])
		

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
		params[:active] = 1
    @story = Story.new(params[:story])
		
    respond_to do |format|
      if @story.save
				Polyco.create(:subject => @story, :object => @context, :state => "active")
        # flash[:notice] = 'Story was successfully created.'
        format.html { redirect_to polymorphic_url(@context, :context => @story.id) }
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

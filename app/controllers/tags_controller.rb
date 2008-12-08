class TagsController < ApplicationController
	
	protect_from_forgery :except => [:suggest]
	before_filter :find_tag, :except => [:index]
	before_filter :find_perspective, :find_user, :find_everyone, :only => [:show, :preview, :suggest, :share]
	after_filter :update_session, :only => [:show]
  # GET /tags
  # GET /tags.xml
  def index
  	
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show	
		@page = params[:page] || 1
		@order = params[:order] || "created_at DESC"
		redirect_to "/users/show/#{current_user.id}" if @tag == current_user.tag
		@kind = params[:kind].singularize rescue @tag.kind
		# @list = List.new(:label => @kind, :creator => current_user)
		# @tag.kind = @kind
		@source = @tag
		
		@title = "#{@kind.capitalize}: #{@tag.label.capitalize}"
		@input = params[:input] || nil
		@service = @user.login
		
		@mode = params[:mode] ||  (session[:mode].nil? ? 'card' : session[:mode])
		@mode = @mode.blank? ? 'card' : @mode
		
		if @perspective.kind == "service"
			@items = service_items(@tag.label)
		
		else
			@items = Connection.with_object(@tag).tagged(params[:input]).with_user_list.distinct.order_by(params[:order]).paginate(:page => @page, :per_page => 12)
		end
		
		respond_to do |f|
			f.html {
				@categories = Connection.with_object(@tag).gather_tags
			}
			f.js {
				render :layout => false
			}
		end
	
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new
    @tag = Tag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/1/edit
  def edit
   
		@tags = @tag.tags
    respond_to do |format|
      format.html {}
      format.xml  { render :xml => @tag }
    end
		# redirect_back_or_default(@tag)
  end

  # POST /tags
  # POST /tags.xml
  def create
		@tag = Tag.find_or_create(:label => params[:label], :kind => params[:kind])

    respond_to do |format|
        flash[:notice] = 'Tags were successfully created.'
        format.html { redirect_back_or_default("/my_nuniverse") }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag  }
				format.js { render :action => "instance"}
    end
  end

  # PUT /tags/1
  # PUT /tags/1.xml
  def update

		@object = Tag.find(params[:object]) rescue nil
		if @object.nil? || @object == @tag
			@tag.tag_with(params[:tags].split(','));
		else
			@tag.connect_with(@object, :user => current_user, :as => params[:tags].split(','));
		end
		
		
		respond_to do |f|
			f.html {redirect_back_or_default "/"}
			f.js { render :action => "preview"}
		end
  end

  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end

	def suggest

		@input = params[:input]
		@mode = session[:mode]
		@kind = params[:kind].downcase

		if @kind.nil?
			if @input.match(/(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/)
				if @input.match(/.*\.(jpg|jpeg|gif|png)/)
					@kind = "image"
				else
					@kind = "bookmark"
				end
			end
		end
		
		
		
		if @kind == "address"
			@source = Tag.find(params[:nuniverse])
			render(:action => "google_locations", :layout => false)
		else
			@suggestions = Tag.with_label_like(@input).paginate(:per_page => 12, :page => 1)
		
		end
	end


	
	def preview
		@page = params[:page] || 1

		if @tag.service.nil?			
			@items = Connection.with_object(@tag)
		end
		
		respond_to do |format|
			format.html {redirect_to @source}
			format.js {
				render :action => "preview", :layout => false
			}
		end
	end
	
	def categorize
		@context = Tag.find(params[:context])
		@connections = Tagging.find(:all, :conditions => ['subject_id = ? AND subject_id = ?',params[:context],params[:id] ])

	end
	
	def share
		@emails = params[:input].split(',')
		@nuniverse = Tag.find_by_id(params[:nuniverse])
		users = User.find(:all, :conditions => ['email in (?)',@emails])
		current_user.email_to(
			:emails => @emails, 
			:content => @nuniverse, 
			:message => params[:message], 
			:items => @nuniverse.connections(:perspective => @perspective))
			
		respond_to do |format|
			format.html { redirect_to @nuniverse}
		end
		
	end
	
	
	
	protected
	
	def find_tag
		
		if params[:id]
			@tag = Tag.find(params[:id]) 
		elsif params[:url]
			@tag = Tag.with_url(params[:url]).first
		else
			@tag = Tag.with_kind(params[:kind]).with_label(params[:input]).first
		end
	end

	
end

class ListsController < ApplicationController
	
	before_filter :login_required
	before_filter :find_user, :only => [:show]
	#before_filter :admin_required, :except => [:show, :create, :find_or_create, :find_or_add_item]
  after_filter :store_location, :only => [:show]
	after_filter :update_session, :only => [:show]

	# GET /lists
  # GET /lists.xml
  def index		
    @lists = List.find(:all, :order => "created_at DESC")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lists }
    end
  end

  # GET /lists/1
  # GET /lists/1.xml
  def show
		
  	if params[:id] 
   		@list = List.find(params[:id]) 
   	else
			@list = List.new(:creator => @user, :label => params[:kind].gsub(/\_|\-/,' '), :tag_id => params[:tag])
		end
			@selected = params[:selected].to_i || nil
			@page = params[:page]
			@mode = params[:mode] || (session[:mode].nil? ? 'card' : session[:mode])
			@order = params[:order] || "by_name"
			@title = @list.title
			@info = params[:info] || nil
			@service = params[:user]

			
			@source = @list
			@kind = @list.kind
			@items = @list.items(:page => @page, :per_page => 11, :order => @order, :perspective => @service)  
	
			respond_to do |format|
				format.html {}
				format.js {render :action => "page", :layout => false}
			end
  end

  # GET /lists/new
  # GET /lists/new.xml
  def new
    @list = List.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @list }
    end
  end

  # GET /lists/1/edit
  def edit
    @list = List.find(params[:id])
  end

  # POST /lists
  # POST /lists.xml
  def create
    @list = List.new(params[:list])

    respond_to do |format|
      if @list.save
        flash[:notice] = 'List was successfully created.'
        format.html { redirect_to(@list) }
        format.xml  { render :xml => @list, :status => :created, :location => @list }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lists/1
  # PUT /lists/1.xml
  def update
    @list = List.find(params[:id])

    respond_to do |format|
      if @list.update_attributes(params[:list])
        flash[:notice] = 'List was successfully updated.'
        format.html { redirect_to(@list) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /lists/1
  # DELETE /lists/1.xml
  def destroy
    @list = List.find(params[:id])
		restrict_to(@list.creator)
    @list.destroy

    respond_to do |format|
      format.html { redirect_back_or_default("/my_nuniverse") }
      format.xml  { head :ok }
    end
  end

	def find_or_create
		@list = List.find(:first, :conditions => ["label = ? AND creator_id = ?",params[:query], current_user.id])
		unless @list
			@list = List.create(
				:label => params[:query],
				:creator_id => current_user.id
			)
		end
		redirect_to @list
	end
	
	def find_or_add_item
		@list = List.find(params[:id])
		@tag = Tag.find_or_create(:label => params[:query], :kind => 'tag')
		@tagging = Tagging.find_or_create(:subject_id => @list.tag.id, :object_id => @tag.id)
		redirect_to @list
	end
	
	protected
	

		
end

class ListsController < ApplicationController
	
	before_filter :login_required
	before_filter :find_user, :find_everyone, :find_perspective, :only => [:show]
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
			@list = List.find_or_create(:label => params[:kind])
		end
			@selected = params[:selected].to_i || nil
			@page = params[:page]
			@mode = params[:mode] || (session[:mode].nil? ? 'card' : session[:mode])
			@order = params[:order] || "by_name"
			@title = @list.title
			@info = params[:info] || nil
			
			@tag = Tag.find(params[:tag]) rescue nil
			@tags =  [@list.label]
			@tags << @tag unless @tag.nil?
			@source = @list
			@kind = @list.kind
			

			if @perspective.kind == "service"
				
			else
				@items = Tagging.select(
					:perspective => @perspective,
					:subject => @list.tag,
					:order => @order,
					:page => @page,
					:per_page => @per_page || 11
					)
				
			end

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
		@list.creator = current_user

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
    @list = List.find(:first, :conditions => ["label = ? AND creator_id = ?",params[:query], current_user.id])
		restrict_to(@list.creator)
    @list.destroy

    respond_to do |format|
      format.html { redirect_back_or_default("/my_nuniverse") }
      format.xml  { head :ok }
    end
  end

	def find_or_create
	
		@list = List.find(:first, :conditions => ["label = ? AND creator_id = ?",params[:label], current_user.id])
		unless @list
			@list = List.create(
				:label => params[:label],
				:creator_id => current_user.id
			)
		end
		redirect_to @list
	end
	
	def find_or_add_item
		@source = Tag.find(params[:nuniverse])
		@kind = params[:kind]
		find_perspective
		if params[:kind] == "image"
			@source.add_image( :source_url => params[:label])
		else
		
			if params[:kind] == "address"
				@tag = Tag.find_or_create(:label => params[:label], :kind => @kind, :data =>"#latlng #{params[:latlng]}"  )
			elsif params[:tag]
				@tag = Tag.find(params[:tag])
			else
				@tag = Tag.find_or_create(:label => params[:label], :kind => @kind, :url => params[:url], :data => params[:data])
			end
			@tagging = Tagging.find_or_create(:subject => @source, :object => @tag, :user => current_user, :kind => @kind)
			Tagging.find_or_create(:subject => @tag, :object => @source, :user => current_user, :kind => @source.kind) unless @source.kind == "user"
		end
		
	

		respond_to do |format|
			format.html {redirect_to @source}
			format.js {
				if params[:kind] == "image"
					render :nothing => true
				else
				render :action => "add", :layout => false
			end
			}
		end
		
	end
	
	def suggest
		@input = params[:input]
		@nuniverse = params[:nuniverse] 
 		@lists = List.find(:all, :conditions => ["label rlike ? ",@input])
	end
	
	protected
	

		
end

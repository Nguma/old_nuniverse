class TagsController < ApplicationController
	
	protect_from_forgery :except => [:suggest]
	before_filter :find_tag, :except => [:index]
	before_filter :find_user, :only => [:show]
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
		@kind = params[:kind].singularize rescue @tag.kind
		@list = List.new(:label => @kind, :creator => current_user)
		@tag.kind = @kind
		@source = @tag
		@page = params[:page] || 1
		@title = "#{@kind.capitalize}: #{@tag.label.capitalize}"
		
		@service = params[:service] || "everyone"
		@order = params[:order] || "latest"
		@mode = params[:mode] ||  (session[:mode].nil? ? 'card' : session[:mode])

		
		
		respond_to do |format|
			format.html {}
			format.js {
				@items = Tagging.select(
					:page => @page,
					:per_page => 3,
					:users => [current_user],
					:tags => [@tag.label, @kind],
					:perspective => @service
				)
				
				render :action => :page, :layout => false
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
    @tag = Tag.find(params[:id])
		# redirect_back_or_default(@tag)
  end

  # POST /tags
  # POST /tags.xml
  def create
		
		@tagging = Tag.connect(
			:label 	=> params[:label],
			:kind			=> params[:kind],
			:path			=> params[:path],
			:restricted => params[:restricted] || 1,
			:description => params[:description],
			:user_id	=> current_user.id
		)
		
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
    @tag = Tag.find(params[:id])
		@tag.update_with(params)
		
		
    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = 'Tag was successfully updated.'
        format.html { redirect_back_or_default "/my_nuniverse" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
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
		@tags = Tag.with_label_like(params[:label]).with_kind_like(params[:kind]).paginate(
			:per_page => 10,
			:page => 1
		)
	end
	
	def images
		@tag = Tag.find(params[:id])
		
	end
	
	def bookmark
		@object = Tag.find_by_url(params[:url])
		@object = Tag.create(
			:label => params[:label],
			:kind => params[:kind],
			:url => params[:url],
			:service =>params[:service],
			:data => params[:data],
			:description => params[:description] ) if @object.nil?
		
		params[:kind].split('#').each do |k|	
			Tagging.create(
				:object => @object,
				:subject => @tag,
				:owner => current_user,
				:kind => k)
		end
			
		respond_to do |format|
			format.html {redirect_back_or_default @tag, :service => params[:service] || nil	}
			format.js { head :ok}
		end
		
		
	end
	
	protected
	
	def find_tag
		if params[:id]
			@tag = Tag.find(params[:id]) 
		else
			conditions = []
			conditions << "label = #{params[:label]}" if params[:label]
			
			@tag = Tag.find(:first, :conditions => conditions.join(" AND "))
		end
	end

	
end

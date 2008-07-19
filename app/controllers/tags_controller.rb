class TagsController < ApplicationController
	
  # GET /tags
  # GET /tags.xml
  def index
    @tags = Tag.paginate(:page => 1, :per_page => 40, :order => "updated_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show		
		session[:path] = params[:path] || session[:path]
		@path = TaggingPath.new session[:path]
		@tag  = @path.last_tag
		@page = params[:page] || 1
		@filter = params[:filter] || nil
	
		
    respond_to do |format|
      format.html {
					session[:perspective] = params[:perspective] || "you"
					@perspective = session[:perspective]
			}
      format.xml  { render :xml => @tag }
			format.js 	{ 
				@perspective = session[:perspective]
				render :action => :page
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
  end

  # POST /tags
  # POST /tags.xml
  def create
		#	gumies = params[:gum].to_s.scan(/\s*\[?(#([\w_]+)\s+([^#|\[\]]+))\]?/)
		# @tags = []
		# 		for gumi in gumies
		#     	tag = Tag.new(:kind => gumi[1], :content => gumi[2])
		# 			tag.save
		# 			@tags << tag
		# 		end
		# raise params[:description].inspect
		@tagging = Tag.connect(
			:content 	=> params[:content],
			:kind			=> params[:kind],
			:path			=> params[:path],
			:restricted => params[:restricted] || 1,
			:description => params[:description],
			:user_id	=> current_user.id
		)
		
    respond_to do |format|
        flash[:notice] = 'Tags were successfully created.'
        format.html { redirect_back_or_default("/nuniverse_of/#{@tagging.path}") }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag  }
				format.js { render :action => "instance"}
    end
  end

  # PUT /tags/1
  # PUT /tags/1.xml
  def update
    @tag = Tag.find(params[:id])
    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = 'Tag was successfully updated.'
        format.html { redirect_to(@tag) }
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

	def section
		session[:path] = params[:path] || session[:path]
		@path = TaggingPath.new session[:path]
		@tag  = @path.last_tag
		@page = params[:page] || 1
		@filter = params[:filter] || nil
		session[:perspective] = params[:perspective] || session[:perspective]
		@perspective = params[:perspective] || "me"
	end

	def page
		
	end
	
	def bookmark
		
	end
end

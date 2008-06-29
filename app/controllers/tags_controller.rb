class TagsController < ApplicationController
	
  # GET /tags
  # GET /tags.xml
  def index
    @tags = Tag.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    @tag = Tag.find(params[:id])
		@filter = params[:filter] || nil
		@taggeds = Tag.find(:all, :conditions => ['kind = ?',@filter])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
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
		
		@tag = Tag.new(:content => params[:content], :kind => params[:kind])
		@tag.save

    respond_to do |format|
        flash[:notice] = 'Tags were successfully created.'
        format.html { redirect_back_or_default(@tag) }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag  }
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
end

class TagsController < ApplicationController
	
	protect_from_forgery :except => [:suggest]
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
		@tag = Tag.find(params[:id])
	
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
		#     	tag = Tag.new(:kind => gumi[1], :label => gumi[2])
		# 			tag.save
		# 			@tags << tag
		# 		end
		# raise params[:description].inspect
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

		if(params[:address])
			@tag.replace('address',params[:address])
		end
		
    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = 'Tag was successfully updated.'
        format.html { redirect_to "/my_nuniverse" }
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
	
	
end

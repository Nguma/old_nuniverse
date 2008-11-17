class TagsController < ApplicationController
	
	protect_from_forgery :except => [:suggest]
	before_filter :find_tag, :except => [:index]
	before_filter :find_perspective, :find_user, :find_everyone, :only => [:show, :preview]
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
		# @list = List.new(:label => @kind, :creator => current_user)
		# @tag.kind = @kind
		@source = @tag
		@page = params[:page] || 1
		@title = "#{@kind.capitalize}: #{@tag.label.capitalize}"
		
		@service = @user.login
		@order = params[:order] || "latest"
		@mode = params[:mode] ||  (session[:mode].nil? ? 'card' : session[:mode])
		@mode = @mode.blank? ? 'card' : @mode
		if @perspective.kind == "service"
			@items = service_items(@tag.label)
		else
		@items = Tagging.select(
			:page => @page,
			:per_page => 16,
			:subject => @tag,
			:perspective => @perspective
		)
		end
		
		
		respond_to do |format|
			format.html {}
			format.js {
				@items = Tagging.select(
					:page => @page,
					:per_page => 16,
					:subject => @tag,
					:label => params[:input],
					:perspective => @perspective
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
		@input = params[:input]
		@nuniverse = params[:nuniverse]
		@mode = session[:mode]
		@kind = params[:kind]
		
		if params[:kind].nil?
			if @input.match(/(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/)
				if @input.match(/.*\.(jpg|jpeg|gif|png)/)
					@kind = "image"
				else
					@kind = "bookmark"
				end
			end
		end
		
		if params[:kind] == "address"
				@source = Tag.find(params[:nuniverse])
			render(:action => "google_locations", :layout => false)
		else
		
			@tags = Tag.with_label_like(@input).with_kind(@kind).paginate(
				:per_page => 3,
				:page => 1
			)
		end
	end
	
	def connect

		@source = Tag.find(params[:nuniverse])
		@kind = params[:kind]
	
		find_perspective

		if @tag.nil?
			@tag = Tag.create(:label => params[:label], :kind => @kind, :url => params[:url], :data => params[:data])
		end
		
		if params[:kind] == "image"
			@tag.add_image( :source_url => params[:label])
		end
		@tagging = Tagging.find_or_create(:subject => @source, :object => @tag, :user => current_user, :kind => @kind)
		Tagging.find_or_create(:subject => @tag, :object => @source, :user => current_user, :kind => @source.kind) unless @source.kind == "user"




		respond_to do |format|
			format.html {redirect_to @source}
			format.js {
				render :action => "connect", :layout => false
			}
		end
	end
	
	def preview
		@page = params[:page] || 1
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
						:object => @tag,
						:subject => @object,
						:owner => current_user.tag,
						:kind => k)
				end
				

				begin
					if params[:kind] == 'bookmark'  && @object.url.match('en.wikipedia.org/wiki/')
							t = @object.url.gsub(/.*\/wiki/,'/wiki')

							@tag.replace_property('wikipedia_url',t)
							wiki_content = Nuniverse.get_content_from_wikipedia(t)
							@tag.description = Nuniverse.wikipedia_description(wiki_content) if @tag.description.nil?

							img = (wiki_content/'table.infobox'/:img).first
							unless (img.nil? || img.to_s.match(/Replace_this_image|Flag_of/) && @tag.images.empty?)
								@image = @tag.add_image(:source_url => img.attributes['src'])
							end
							@tag.save
					end
				rescue
				end
			
			
		respond_to do |format|
			format.html {redirect_back_or_default @tag, :service => params[:service] || nil	}
			format.js { render :layout => false}
		end
		
		
	end
	
	protected
	
	def find_tag
		if params[:id]
			@tag = Tag.find(params[:id]) 
		else
			@tag = Tag.with_label(params[:label]).with_kind(params[:kind]).find(:first)
		end
	end

	
end

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

		@kind = params[:kind].singularize rescue @tag.kind
		# @list = List.new(:label => @kind, :creator => current_user)
		# @tag.kind = @kind
		@source = @tag
		@page = params[:page] || 1
		@title = "#{@kind.capitalize}: #{@tag.label.capitalize}"
		@input = params[:input] || nil
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
				:label => @input,
				:perspective => @perspective,
				:order => @order
			)
			@categories = Tagging.paginate_by_sql(
			"SELECT TA.kind as name,  count(DISTINCT TA.object_id) AS counted FROM taggings TA WHERE TA.user_id = #{current_user.tag.id} AND subject_id = #{@tag.id} GROUP BY TA.kind ORDER BY TA.kind ASC",
			:page => params[:page] || 1,
			:per_page => 50)			
		end
		
		
		respond_to do |format|
			format.html {}
			format.js {
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
			@tags = Tagging.select(
				:perspective => @everyone.perspectives.first,
				:kind => @kind || nil,
				:label => @input,
				:per_page => 5,
				:page => params[:page] || 1
				)
		
			# @tags = Tag.with_label_like(@input).with_kind(@kind).paginate(
			# 			:per_page => 3,
			# 			:page => 1
			# 		)
		end
	end
	
	def disconnect 
		@source = Tag.find(params[:nuniverse])
		set = [params[:nuniverse], params[:item]]
		connections = Tagging.find(:all, :conditions => ['subject_id in (?) AND object_id in (?) AND user_id = ?', set, set, current_user.tag])
		connections.each do |c|
			c.destroy
		end
		redirect_to @source
	end
	
	def connect

		@source = Tag.find(params[:nuniverse])
		@kind = params[:kind]

		@tags = params[:tags].split(',') rescue nil
	
		find_perspective
		
		if params[:input].blank?
			if !params[:description].blank?
				params[:input] = params[:description].split(/\n/)[0]
				
			else
				params[:input] = "#{@kind} of #{@source.label}"
			end

		end
	
				
		@tag = Tag.create!(
			:label => params[:input], 
			:kind => @kind, 
			:url => params[:url], 
			:data => params[:data], 
			:description => params[:description], 
			:service => params[:service]) if @tag.nil?
			
		
		
		 @tagging = @tag.connect_with(@source, :as => @tags, :user => current_user)
		
		
		if @kind == "address"
			@tag.label = @tag.property('address')
			@tag.save
			if !@tag.property('tel').blank?
				tel = Tag.find_or_create(:label => @tag.property('tel'), :kind => 'telephone')
				@source.connect_with(tel, :user => current_user)
			end
	
		
		elsif @kind == "image"
			@tag.add_image( :source_url => params[:input], :uploaded_data => params[:uploaded_data])
		end
		
		
				
		
			if @kind == 'bookmark'  && @tag.url.match('en.wikipedia.org/wiki/')
				@tag.label = @tag.label.gsub(/\,\s+the free encyclopedia/, "")
				@tag.save
					t = @tag.url.gsub(/.*\/wiki/,'/wiki')

					@source.replace_property('wikipedia_url',t)
					wiki_content = Nuniverse.get_content_from_wikipedia(t)
					
					@source.description = Nuniverse.wikipedia_description(wiki_content) if @source.description.nil?

					img = (wiki_content/'table.infobox'/:img).first
					unless (img.nil? || img.to_s.match(/Replace_this_image|Flag_of/))
						image = Tag.find_or_create(:label => img.attributes['src'].split('/').last, :kind => 'image', :url => img.attributes['src'])
						@image = image.add_image(:source_url => img.attributes['src'])
						image.connect_with(@source, :user => current_user)
									
					end
					@source.save
					
			end
			

		respond_to do |format|
			format.html {redirect_to @source}
			format.js {
				render :action => "connect", :layout => false
			}
		end
	end
	
	def preview
		@page = params[:page] || 1
		if @tag.service.nil?
			@items = Tagging.paginate_by_sql(
			"SELECT TA.*,  count(DISTINCT TA.object_id) AS counted FROM taggings TA WHERE TA.subject_id = #{@tag.id} GROUP BY TA.kind ORDER BY counted ASC",
			:page => 1,
			:per_page => 10)

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
		@connections = Tagging.find(:all, :conditions => ['subject_id = ? AND object_id = ?',params[:context],params[:id] ])

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

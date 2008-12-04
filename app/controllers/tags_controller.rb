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
			@items = Connection.with_user(@perspective.members).with_subject(@tag).tagged(params[:input]).with_user_list.distinct.order_by(params[:order]).paginate(:page => @page, :per_page => 12)
		end
		
		respond_to do |format|
			format.html {
				@categories = Tagging.gather.with_user(@perspective.members).with_subject(@tag).paginate(:page => @page, :per_page => 10)
			}
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
   
		@tags = Tagging.gather_with_user_list.with_object(@tag)

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
		@tag.connect_with(params[:subject] || current_user.tag, :user => current_user, :as => params[:tags].split(','));
		
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

		
			@suggestions = Connection.named(@input).distinct.paginate(:per_page => 12, :page => 1)
		end
	end
	
	def disconnect 
		
		@item = Tag.find(params[:item])
		set = [@tag, @item]
		connections = Connection.with_user(current_user).with_subject(set).with_object(set)

		connections.each do |c|
			c.destroy
		end
		redirect_to @tag
	end
	
	def connect

		# @source = Tag.find(params[:id])
		@kind = params[:kind]

		@tags = params[:tags].split(',') rescue []
		# @tags << @kind
	
		find_perspective
		
		if params[:input].blank?
			if !params[:description].blank?
				params[:input] = params[:description].split(/\n/)[0]
				
			elsif @kind == "bookmark"
				doc = Hpricot open( params[:url])

				params[:input] = (doc/:title).first.inner_html.to_s
				params[:description] ||= (doc/:p).first.inner_html.to_s rescue ""
			else
				params[:input] = "#{@kind} of #{@tag.label}"
			end

		end

		@object = Tag.find_or_create(
			:label => params[:input], 
			:kind => @kind, 
			:url => params[:url], 
			:data => params[:data], 
			:description => params[:description], 
			:service => params[:service]
		)

		
		
		 @tagging = @object.connect_with(@tag, :as => @tags, :user => current_user, :comment => params[:comment])
		
		
		if @kind == "address"
			@object.label = @object.property('address')
			@object.save
			if !@object.property('tel').blank?
				tel = Tag.find_or_create(:label => @object.property('tel'), :kind => 'telephone')
				@object.connect_with(tel, :user => current_user)
			end
	
		
		elsif @kind == "image"
			@object.add_image( :source_url => params[:input], :uploaded_data => params[:uploaded_data])
		end
		
		
				
		
			if @kind == 'bookmark'  && @object.url.match('en.wikipedia.org/wiki/')
				@object.label = @object.label.gsub(/\,\s+the free encyclopedia/, "")
				@object.save
					t = @object.url.gsub(/.*\/wiki/,'/wiki')

					@tag.replace_property('wikipedia_url',t)
					wiki_content = Nuniverse.get_content_from_wikipedia(t)
					
					@tag.description = Nuniverse.wikipedia_description(wiki_content) if @tag.description.nil?

					img = (wiki_content/'table.infobox'/:img).first
					unless (img.nil? || img.to_s.match(/Replace_this_image|Flag_of/))
						image = Tag.find_or_create(:label => img.attributes['src'].split('/').last, :kind => 'image', :url => img.attributes['src'])
						@image = image.add_image(:source_url => img.attributes['src'])
						image.connect_with(@tag, :user => current_user)
									
					end
					@tag.save
					
			end
			

		respond_to do |format|
			format.html {redirect_to @tag}
			format.js {
			
			}
		end
	end
	
	def preview
		@page = params[:page] || 1
		if @tag.service.nil?
			# @items = Tagging.paginate_by_sql(
			# "SELECT TA.*,  count(DISTINCT TA.object_id) AS counted FROM taggings TA WHERE TA.subject_id = #{@tag.id} GROUP BY TA.kind ORDER BY counted ASC",
			# :page => 1,
			# :per_page => 10)
			
			@items = Connection.with_subject(@tag).by_kind.paginate(:page => 1, :per_page => 10)

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

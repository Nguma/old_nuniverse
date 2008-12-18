class TagsController < ApplicationController
	
	protect_from_forgery :except => [:suggest]
	before_filter :find_tag, :except => [:index, :remove_tag]
	before_filter :find_perspective, :find_user, :find_everyone, :only => [:show, :preview, :suggest, :share]
	after_filter :update_session, :only => [:show]
	after_filter :store_location, :only => [:show]
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

		# redirect_to "/users/show/#{current_user.id}" if @tag == current_user.tag
		@mode = params[:mode] || (session[:mode] ? session[:mode] : 'card')
		@kind = params[:kind] || (session[:kind] ? session[:kind] : 'digest')
		@order = params[:order] || (session[:order] ? session[:order] : 'by_latest')

		@filter = params[:input].blank? ? nil : params[:input]
		# @list = List.new(:label => @kind, :creator => current_user)
		# @tag.kind = @kind
		@source = @tag
		
		@title = "#{@tag.kind}: #{@tag.label.capitalize}"
		@input = params[:input] || nil
		@service = @user.login
		
		# @subject_kind = @kind == "digest" ? nil : @kind
		if @kind == "digest"
			@nuniverses = Connection.with_object(@tag).with_subject_kind('nuniverse|bookmark|user').order_by("by_latest").paginate(:page => 1, :per_page => 15)

		elsif @perspective.kind == "service"
			@items = service_items(@tag.label)
		else
			@items = Connection.with_object(@tag).with_subject_kind(@kind).tagged_or_named(@filter).order_by(@order).paginate(:page => @page, :per_page => 15)
			@count = Connection.with_object(@tag).count
		end
		
		
	
		respond_to do |f|
			f.html {
				@categories = Connection.with_object(@tag).with_subject_kind(@subject_kind).gather_tags
			}
			f.js {
				
				
			}
		end
	
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new

    @tag = Tag.new(:label => params[:input])
		@object = Tag.find(params[:object]) rescue nil
		@tags = params[:tags] || []
		@images = []
		@wikis = []
	
		if params[:url] 
			if params[:url].match('en.wikipedia.org/wiki/')
				feed_url = "http://en.wikipedia.org/w/api.php?action=query&list=allimages&aifrom=#{params[:url].gsub('http://en.wikipedia.org/wiki/','')}&format=xml"
				
				response = Net::HTTP.get_response(URI.parse(feed_url)).response.body
				@images =  REXML::Document.new(response).elements.to_a("//img").collect {|c| c.attributes['url']}
			else
				doc = Hpricot open(params[:url].gsub(/\s|,/,'_'))
				@images = (doc/:img).collect! {|img| img if not img.attributes['height'].to_i < 50 }
				@description = (doc/:p).first.inner_html.gsub(/\..*/,'') rescue ""
			end
		
		else
				feed_url = "http://en.wikipedia.org/w/api.php?action=opensearch&search=#{@tag.label.gsub(' ','_')}&format=xml"
				response = Net::HTTP.get_response(URI.parse(feed_url)).response.body
				ds = REXML::Document.new(response).elements.to_a("//Item")
				ds.each do |d|
					@wikis << Tag.new(:label => d.elements["Text"].text, :description => d.elements["Description"].text, :url => d.elements["Url"].text, :kind => "bookmark")
				end
				feed_url = "http://en.wikipedia.org/w/api.php?action=query&list=allimages&aifrom=#{@tag.label.gsub(' ','_')}&format=xml"
				response = Net::HTTP.get_response(URI.parse(feed_url)).response.body
				@images =  REXML::Document.new(response).elements.to_a("//img").collect {|c| c.attributes['url']}
		end
				
				

				
				
			# 	@images = ds.collect {|c| c.elements["url"].text}
			


    respond_to do |format|
      format.html {}
			format.js {}
      format.xml  { render :xml => @tag }
    end
  end

	def create
		@object = Tag.find(params[:object]) rescue nil
		@tag = Tag.new(:label => params[:input], :kind => "nuniverse", :description => params[:description])
		@tag.tag_with(params[:tags].split(','))
		@tag.save
		@tag.connect_with(@object, :description => params[:connection_description]) if @object 
		if !params[:source_url].blank? || !params[:uploaded_data].blank?
			 if @image = Image.create!(:source_url => params[:source_url].blank? ? nil : params[:source_url], :uploaded_data => params[:uploaded_data])
 					@image.tag.connect_with(@tag)
				end
		end
		
		if params[:url] && !params[:url].blank?
			bookmark = Tag.find(:first, :conditions => ['url = ?',params[:url]] )
			if bookmark.nil?
				bookmark = Nuniversal.parse_url(params[:url]) 
				bookmark.save
			end

			bookmark.connect_with(@tag)
		end
		respond_to do |f|
			f.html { redirect_to @object rescue redirect_to @tag }
			f.js {}
		end
	end

  # GET /tags/1/edit
  def edit
   
		@tags = @tag.taggings
    respond_to do |format|
      format.html {}
      format.xml  { render :xml => @tag }
    end
		# redirect_back_or_default(@tag)
  end



  # PUT /tags/1
  # PUT /tags/1.xml
  def update

		@object = Tag.find(params[:object]) rescue nil
		if @object.nil? || @object == @tag
			@tags = params[:tags].split(',')
			@tag.taggings.each do |tagging|
				if !@tags.include?(tagging.predicate)
					tagging.destroy
				end
			end
				
			@tag.tag_with(@tags);
		else
			@tag.connect_with(@object, :user => current_user, :as => params[:tags].split(','));
		end
		
		
		respond_to do |f|
			f.html {redirect_to visit_url(@tag.id, current_user.tag) }
			f.js { render :action => "preview"}
		end
  end

	def add_tag 
		@tagging = @tag.tag_with(params[:tag].to_a)
		respond_to do |f|
			f.html {redirect_to visit_url(@tag.id, current_user.tag) }
			f.js { render :action => "add_tag"}
		end
	end
	
	def remove_tag 
		t = Tagging.find(params[:id])
		t.destroy()
		respond_to do |f|
			f.html {redirect_to visit_url(@tag.id, current_user.tag) }
			f.js { render :nothing => true}
		end
	end
	
  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
  
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end

	def create_email
		@filter = params[:filter]
	end

	def send_email
		@filter = params[:filter].blank? ? nil : params[:filter]
		@emails = params[:emails].split(/\,|\;/)
		UserMailer.deliver_list(
			:sender => current_user,
			:emails => params[:emails],
			:tag => @tag,
			:connections => Connection.with_object(@tag).with_subject_kind(session[:kind]).tagged_or_named(@filter).order_by(session[:order]).paginate(:page => 1, :per_page => 15),
			:message => params[:message])	
		respond_to do |f|
			f.html {redirect_to @tag }
			f.js {}
		end
	end

	def suggest
		@input = params[:input]
		if @input
			@suggestions = Tag.with_label_like(@input).with_kind('nuniverse').paginate(:per_page => 12, :page => 1)
		else
			render :nothing => true
		end
		respond_to do |f|
			f.html {}
			f.js {}
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

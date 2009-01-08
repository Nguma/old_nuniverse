class TagsController < ApplicationController
	
	protect_from_forgery :except => [:suggest]
	before_filter :find_tag, :except => [:index, :remove_tag]
	before_filter  :find_user, :only => [:show, :preview, :suggest, :share]
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
	
	
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new

    @tag = Tag.new(:name => params[:input])
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

		@tag = Tag.new()
		respond_to do |f|
			f.html { redirect_back_or_default('/') }
			f.js {}
		end
	end

  # GET /tags/1/edit
  def edit

    respond_to do |format|
      format.html {}
      format.xml  { render :xml => @tag }
    end
		# redirect_back_or_default(@tag)
  end



  # PUT /tags/1
  # PUT /tags/1.xml
  def update
		
		respond_to do |f|
			f.html {redirect_back_or_default('/') }
			f.js { render :action => "preview"}
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

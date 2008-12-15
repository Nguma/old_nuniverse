class TagsController < ApplicationController
	
	protect_from_forgery :except => [:suggest]
	before_filter :find_tag, :except => [:index, :remove_tag]
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

		# redirect_to "/users/show/#{current_user.id}" if @tag == current_user.tag
		@mode = params[:mode] || (session[:mode] ? session[:mode] : 'card')
		@kind = params[:kind] || (session[:kind] ? session[:kind] : 'digest')
		@order = params[:order] || (session[:order] ? session[:order] : 'by_latest')

		@filter = params[:input] 
		# @list = List.new(:label => @kind, :creator => current_user)
		# @tag.kind = @kind
		@source = @tag
		
		@title = "#{@tag.kind}: #{@tag.label.capitalize}"
		@input = params[:input] || nil
		@service = @user.login
		
		@mode = params[:mode] ||  (session[:mode].nil? ? 'card' : session[:mode])
		@mode = @mode.blank? ? 'card' : @mode
		

		@subject_kind = @kind == "digest" ? nil : @kind
		if @perspective.kind == "service"
			@items = service_items(@tag.label)
		else
			@items = Connection.with_object(@tag).with_subject_kind(@subject_kind).tagged_or_named(@filter).order_by(@order).paginate(:page => @page, :per_page => 15)

		end
	
		respond_to do |f|
			f.html {
				@video_count = Connection.with_object(@tag).with_subject_kind('video').count
				@bookmark_count = Connection.with_object(@tag).with_subject_kind('bookmark').count
				@nuniverse_count = Connection.with_object(@tag).with_subject_kind('nuniverse').count
				@location_count = Connection.with_object(@tag).with_subject_kind('location').count
				@user_count = Connection.with_object(@tag).with_subject_kind('user').count
				@image_count = Connection.with_object(@tag).with_subject_kind('image').count
				@comment_count = Connection.with_object(@tag).with_subject_kind('comment').count
				@product_count = Connection.with_object(@tag).with_subject_kind('product').count
				
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

    respond_to do |format|
      format.html {}
			format.js {}
      format.xml  { render :xml => @tag }
    end
  end

	def create
		@object = Tag.find(params[:object]) rescue nil
		@tag = Tag.new(:label => params[:input], :kind => "nuniverse")
		@tag.tag_with(params[:tags].split(','))
		@tag.save
		@tag.connect_with(@object) if @object 
		respond_to do |f|
			f.html {}
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

  # # POST /tags
  # # POST /tags.xml
  # def create
  # 		@tag = Tag.find_or_create(:label => params[:label], :kind => params[:kind])
  # 
  #   respond_to do |format|
  #       flash[:notice] = 'Tags were successfully created.'
  #       format.html { redirect_back_or_default("/my_nuniverse") }
  #       format.xml  { render :xml => @tag, :status => :created, :location => @tag  }
  # 				format.js { render :action => "instance"}
  #   end
  # end

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
    @tag = Tag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end

	def send_email
		@emails = params[:input].split(/\,|\;/)
		UserMailer.deliver_list(
			:sender => current_user,
			:emails => params[:input],
			:tag => @tag,
			:connections => @tag.connections_from,
			:message => params[:message])	
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

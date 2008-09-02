class TaggingsController < ApplicationController
	protect_from_forgery :except => [:create]
	
	before_filter :login_required, :except => [:preview]
	before_filter :find_tagging, :only => [:rate, :bookmark, :unbookmark, :edit, :show, :update, :share, :invite, :destroy, :preview]
	# skip_before_filter :invitation_required
	after_filter :store_location, :only => [:show]

	def index
		redirect_to "/my_nuniverse"
		# @connections = Tagging.paginate(:all, :order => "created_at DESC", :page => 1, :per_page => 20)
	end
	
	def edit
		@items = @tagging.connections.paginate(:page => params[:page] || 1, :per_page => 10)
	end
	
	def update
		restrict_to([@tagging.owner])
		@tagging.object.kind = params[:kind] if params[:kind]
		@tagging.object.replace_property('address', params[:address].to_s) if params[:address]
		@tagging.object.replace_property("tel", params[:tel]) if params[:tel]		
		@tagging.object.replace_property("latlng", params[:latlng]) if params[:latlng]
		@tagging.object.url = params[:url] if params[:url]
		@tagging.object.description = params[:description] if params[:description]
		@tagging.object.save
		redirect_to @tagging
	end
	
	def destroy
		raise "You don't have the right to do this!" if current_user != @tagging.owner
		@parent = @tagging.path.last
		@tagging.destroy
		redirect_back_or_default("/taggings/#{@parent}")
	end
	
	def connect
		gums = params[:query].scan(/\s*\[?(#([\w_]+)\s+([^#|\[\]]+))\]?/)
		unless gums.empty?
			params[:kind] = gums[0][1]
			params[:query] = gums[0][2]
		end
		@subject = Tag.find(params[:subject])
		if params[:kind] == "address"
			@subject.replace_property('address', params[:query])
			@subject.save
		else
			@tag = Tag.find_or_create(:label => params[:query], :kind => params[:kind] || nil)
			@tagging = Tagging.find_or_create(:owner => current_user, :subject_id => @subject.id, :object_id => @tag.id, :path => params[:path])
		end
		redirect_back_or_default("/taggings/#{@tagging.path.last}")
	end
	
	def show
		if @tagging.nil?
			@tagging = Tagging.with_exact_path(TaggingPath.new(params[:path])).first
		end
		restrict_to(@tagging.authorized_users)
		@selected = params[:selected].to_i || nil
		@service = params[:service] || nil
		@page = params[:page] || 1
		@order = params[:order] || "rank"
		
		
		case @service
		when "google"
			query = (@tagging.subject.kind == "user") ? "" : @tagging.subject.label
			query << " #{@tagging.object.label}" 
			@items = Finder::Search.find(:query => query, :service => @service)
		when "map"
			
			
			@items = @tagging.connections.paginate(:page => @page, :per_page => 10)
			render :action => "maps"
		when "images"
			@items = @tagging.images.paginate(:page => @page, :per_page => 10)
			render :action => "images"
		when nil
		else
			
			@service = nil		
				
		end
		@order = "name" if @tagging.object.kind != "list"
		@contributors = @tagging.contributors(:page => @page, :per_page => 10)
		@items = @items.nil? ? @items = @tagging.connections(:order => @order).paginate(:page => @page, :per_page => 10) : @items

	end
	
	def share
		@contributors = @tagging.contributors(:page => params[:page] || 1, :per_page => 10)
	end
	
	def invite
		@user = User.find_by_email(params[:email]) || User.create(:email => params[:email])
		current_user.invite(:user => @user, :topic => @tagging)
		redirect_back_or_default("/taggings/share/#{@tagging.id}")
	end
	
	def add_image
		@avatar = Avatar.new params[:image_url]
    @avatar.tag = @tagging.object
    
    if @avatar.save
      # Avatar.find(:all, :conditions => {:tag_id => params[:tag_id]}).each do |av|
      #        av.destroy unless av.id == @avatar.id
      #      end

      
      redirect_to @tagging
    else
      puts @avatar.errors.inspect
      render :action => "new"
    end
	end
	
	def preview
		@items = @tagging.connections.paginate(:page => 1, :per_page => 5)
	end
	
	def bookmark
		@tag = Tag.create(
			:label => params[:label],
			:kind => params[:kind],
			:url => params[:url],
			:service =>params[:service],
			:data => params[:data],
			:description => params[:description] )
			
		Tagging.create(
			:path => @tagging.full_path,
			:object => @tag,
			:subject => @tagging.object,
			:owner => current_user)
			
		redirect_to @tagging, :service => params[:service] || nil	
	end
	
	def rate
		@ranking = Ranking.find_or_create(:tagging => @tagging, :user => current_user)
		@ranking.value = params[:stars].to_i || 1
		@ranking.save
		redirect_to :back
		# respond_to do |format|
		# 		format.html {render :layout => false}
		# 		format.js { render :layout => false}
		# 	end
	end
	
	protected
	
	def find_tagging
		@tagging = Tagging.find(params[:id]) rescue nil
	end
	
	
end
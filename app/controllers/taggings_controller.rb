class TaggingsController < ApplicationController
	protect_from_forgery :except => [:create]
	
	before_filter :login_required
	before_filter :find_tagging, :only => [:edit, :show, :update, :share, :invite, :destroy]

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
		@tag = Tag.find_or_create(:label => params[:query], :kind => params[:kind] || nil)
		@tagging = Tagging.find_or_create(:owner => current_user, :subject_id => @subject.id, :object_id => @tag.id, :path => params[:path])
		redirect_to("/taggings/#{@tagging.path.last}")
	end
	
	def show
		if @tagging.nil?
			@tagging = Tagging.with_exact_path(TaggingPath.new(params[:path])).first
		end
		restrict_to(@tagging.authorized_users)
		@selected = params[:selected].to_i || nil
		@service = params[:service] || nil
		@page = params[:page] || 1
		@order = params[:order] || "name"
		
		case @service
		when "google"
			@items = Finder::Search.find(:query => "#{@tagging.subject.label} #{@tagging.object.label}", :service => @service)
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
	
	protected
	
	def find_tagging
		@tagging = Tagging.find(params[:id]) rescue nil
	end
	
	
end
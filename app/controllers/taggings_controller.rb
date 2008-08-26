class TaggingsController < ApplicationController
	protect_from_forgery :except => [:create]
	
	before_filter :login_required
	before_filter :find_tagging, :only => [:edit, :show, :share, :invite, :destroy]

	def index
		redirect_to "/my_nuniverse"
		# @connections = Tagging.paginate(:all, :order => "created_at DESC", :page => 1, :per_page => 20)
	end
	
	def edit
		@items = @tagging.connections.paginate(:page => params[:page] || 1, :per_page => 10)
	end
	
	def create
		
		# if params[:id]
		# 			@tagging = Tagging.create Tagging.find(params[:id]).attributes.merge(
		# 				:user_id => current_user.id,
		# 				:path		 => session[:path]
		# 			)
		# 		else
		# 			gum = {}
		# 			gum['address'] = params[:address] 
		# 			if params[:data]
		# 				gumies = params[:data].scan(/\s*#([\w_]+)[\s]+([^#|\[|\]]+)*/)
		# 				unless gumies.empty?
		# 					params[:label] = gumies[0][1]
		# 					params[:kind]    = gumies[0][0]
		# 					gumies.shift
		# 					gumies.each do |gumi|
		# 						gum[gumi[0]] = gumi[1]
		# 					end
		# 				end
		# 			end
		# 		
		# 			params[:description] ||= gum.delete('description')
		# 			params[:url]         ||= gum.delete('url')
		# 			params[:service]     ||= gum.delete('service')
		# 			
		# 			@tagging = Tag.connect(
		# 				:label 	    => params[:label],
		# 				:kind			    => params[:kind],
		# 				:path			    => session[:path],
		# 				:restricted   => params[:restricted],
		# 				:description  => params[:description] || "",
		# 				:url          => params[:url],
		# 				:service      => params[:service],
		# 				:gum          => gum,
		# 				:relationship => params[:relationship],
		# 				:user_id	    => current_user.id
		# 			)
		# 		end
		
    # respond_to do |format|
    #       flash[:notice] = 'Connection was successfully created.'
    #       format.html { render :layout => false }
    #       format.xml  { render :xml => @tag, :status => :created, :location => @tag  }
    #     end
	end
	
	def destroy
		raise "You don't have the right to do this!" if current_user != @tagging.owner
		@parent = @tagging.path.last
		@tagging.destroy
		redirect_back_or_default("/taggings/#{@parent}")
	end
	
	def connect
		@subject = Tag.find(params[:subject])
		@tag = Tag.find_or_create(:label => params[:query], :kind => 'tag')
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
			@items = Finder::Search.find(:query => @tagging.object.label, :service => @service)
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
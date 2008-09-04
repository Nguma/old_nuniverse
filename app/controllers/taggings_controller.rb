class TaggingsController < ApplicationController
	protect_from_forgery :except => [:create]
	#include SMSFu
	
	before_filter :login_required, :except => [:preview]
	before_filter :find_tagging, :except => [:index]
	# skip_before_filter :invitation_required
	after_filter :store_location, :only => [:show]

	def index
		redirect_to "/my_nuniverse"
	end
	
	def edit
		@items = @tagging.connections.paginate(:page => params[:page] || 1, :per_page => 10)
	end
	
	def update
		restrict_to([@tagging.owner])
		
		@tagging.update_with(params)
		redirect_to @tagging
	end
	
	def destroy
		raise "You don't have the right to do this!" if current_user != @tagging.owner
		@parent = @tagging.path.last
		@tagging.destroy
		if @parent 
			redirect_to("/taggings/#{@parent}")
		else
			redirect_to("/my_nuniverse")
		end
		
	end
	
	def connect
		if over_limit
			flash[:error] = "You have reached your max number of connections."
			redirect_to "/upgrade"
		else
			gums = Gum.parse(params[:query])
			unless gums.empty?
				@kind = Nuniverse::Kind.match(gums[0][1])
				params[:query] = gums[0][2]
			end
			@subject = @tagging ? @tagging.object : current_user.tag
			if @kind == "address"
				@subject.replace_property('address', params[:query])
				@subject.save
			elsif @kind == "image"
				@subject.add_image(:source_url => params[:query])
			else
				@tag = Tag.find_or_create(
					:label => Gum.purify(params[:query]), 
					:kind => @kind
				) 
				@tagging = Tagging.find_or_create(
										:label => Gum.purify(params[:query]), 
										:owner => current_user, 
										:subject_id => @subject.id, 
									 	:object_id => @tag.id || nil, 
										:path => @tagging.full_path || ""
									)
			end
			redirect_back_or_default(@tagging)
		end
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
		@filter = params[:filter] || nil
		
		
		case @service
		when "google"
			query = (@tagging.subject.kind == "user") ? "" : @tagging.subject.label
			query << " #{@tagging.object.label}" 
			@items = Googleizer::Request.new(query, :mode => "web").response.results
		when "map"
			
			
			@items = @tagging.connections.paginate(:page => @page, :per_page => 10)
			render :action => "maps"
		when "images"
			@items = @tagging.connections(:order => @order, :filter => @filter).paginate(:page => @page, :per_page => 10)
			# @items = @tagging.images.paginate(:page => @page, :per_page => 10)
			render :action => "images"
		when nil
		else
			
			@service = nil		
				
		end
		@order = "name" if @tagging.object.kind != "list"
		@contributors = @tagging.contributors(:page => @page, :per_page => 10)
		@items = @items.nil? ? @items = @tagging.connections(:order => @order, :filter => @filter).paginate(:page => @page, :per_page => 10) : @items

	end
	
	def share
		@contributors = @tagging.contributors(:page => params[:page] || 1, :per_page => 10)
	end
	
	def invite
		@user = User.find_by_email(params[:email]) || User.create(:email => params[:email])
		current_user.invite(:user => @user, :topic => @tagging)
		redirect_back_or_default("/taggings/share/#{@tagging.id}")
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
	
	def sms
		@items = @tagging.connections.paginate(:page => @page, :per_page => 10)
		
	end
	
	protected
	
	def find_tagging
		
		@tagging = Tagging.find(params[:id]) rescue nil
	end
	
	
end
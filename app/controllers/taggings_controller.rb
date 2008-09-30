class TaggingsController < ApplicationController
	protect_from_forgery :except => [:create]
	#include SMSFu
	
	before_filter :login_required, :except => [:preview, :suggest]
	before_filter :find_tagging, :except => [:index]
	skip_before_filter :invitation_required, :only => [:suggest]
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
			redirect_back_or_default("/taggings/#{@parent}")
		else
			redirect_back_or_default("/my_nuniverse")
		end
		
	end
	
	def show

		@list = params[:list] ? List.new(:label => params[:list], :creator => current_user, :tag_id => params[:tag]) : nil
		@selected = params[:selected].to_i || nil
		@service = params[:service] || "you"
		@page = params[:page] || 1
		@order = params[:order] || ((@tagging.object.kind != "list") ? "rank" : "name")
		@filter = params[:filter] || nil
		
		
		case @service
		when "google"
			query = (@tagging.subject.kind == "user") ? "" : @tagging.subject.label
			query << " #{@tagging.object.label}" 
			@items = Googleizer::Request.new(query, :mode => "web").response.results
		when "amazon"
			@items = Finder::Search.find(:query => @tagging.object.label, :service => 'amazon')
		when "map"
			@items = @tagging.connections(:mode => 'exact', :page => @page)
			render :action => "maps"
		when "images"
			@items = @tagging.connections(:mode => 'exact', :order => @order, :filter => @filter, :page => @page, :per_page => 15)
			
			# @items = @tagging.images.paginate(:page => @page, :per_page => 10)
			render :action => "images"
		when nil
		else
		end
		
		
		@items = @items.nil? ? @items = @tagging.connections(:order => @order, :filter => @filter).paginate(:page => @page, :per_page => 10) : @items
		respond_to do |format|
			format.html {}	
			format.js { render :action => :page, :layout => false}
		end
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
			:object => @tag,
			:subject => @tagging.object,
			:owner => current_user,
			:kind => 'bookmark')
			
		redirect_to @tagging, :service => params[:service] || nil	
	end
	
	def rate
		@ranking = Ranking.find_or_create(:tagging => @tagging, :user => current_user)
		@ranking.value += 1
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
	
	def suggest
		@command = Command.new(params[:command])
		case @command.action
		when "localize"
			@input = params[:input]
			render :action => "google_locations", :layout => false
		when "find","search"
			if @command.argument
				@list = List.new(:creator => current_user, :label => @command.argument)
				@items = @list.items(:label => params[:input])
			else
				@items = current_user.connections(:label => params[:input])
			end
		else
			#@list = List.new(:creator => current_user, :label => "")
			@items = current_user.connections(:label => params[:input])
			
		end
		
	end
	
	protected
	
	def find_tagging
		
		@tagging = Tagging.find(params[:id]) rescue nil
	end
	
	
end
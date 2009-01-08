class NuniversesController < ApplicationController
	
	before_filter :find_user, :only => [:suggest, :show, :command, :index]
	before_filter :find_nuniverse, :except => [:index]
	before_filter :update_session, :only => [:show]
 	after_filter :store_location, :only => [:show]

	def index
		params[:search_terms] ||= ""
		@nuniverses = Nuniverse.search(params[:search_terms],:page => params[:page], :per_page => 40)
	end
	
	def show
		@perspective = params[:perspective]
		@source = @nuniverse
		@context = Story.find(params[:context]) rescue nil
		@connection_to_current = Polyco.with_subject(@source).with_object(@current_user).first
		@connections = @nuniverse.connections.of_klass(@klass)
		

		
		
		case params[:order]
		when "by_latest"
			@connections = @connections.order_by_date.with_score
		when "by_name"
			@connections = @connections.order_by_name.with_score
		else
			@connections = @connections.order_by_score(@perspective).with_score
		end
		
		if @context
			@connections = @connections.sphinx(:per_page => 3000, :conditions => {:context_ids => @context.id})
		end
		if params[:filter]
			@connections = @connections.sphinx(params[:filter], :per_page => 3000)
		end
		
		@connections = @connections.paginate(:per_page => 20, :page => params[:page])
		
		@latest_stories = @nuniverse.connections.of_klass('Story').order_by_date.paginate(:page => 1, :per_page => 5)
		
		@filter = params[:filter]  || nil
	end
	
	def edit
		
	end
	
	def update
		@taggings = []
		params[:nuniverse][:tags].split(',').each do |t|
			tag = Tag.find_or_create(:name => t.strip)
			@taggings << Tagging.new(:taggable => @nuniverse, :tag => tag)
		end
		@nuniverse.taggings = @taggings
		@nuniverse.save
		redirect_back_or_default('/')
	end
	
	

	
	
	protected
	
	def find_nuniverse
		@source = @nuniverse = Nuniverse.find(params[:id])
	end

	
end

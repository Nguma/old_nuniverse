class NuniversesController < ApplicationController
	
	before_filter :find_user, :only => [:suggest, :show, :command, :index]
	before_filter :find_nuniverse, :except => [:index, :suggest]
	before_filter :find_source, :only => [:index]
	before_filter :update_session, :only => [:show]
 	after_filter :store_location, :only => [:show]

	def index
			@input = params[:input] rescue nil
			if @source
				@nuniverses = Nuniverse.search(@input, :page => params[:page] || 1, :per_page => 10)
			else
				@nuniverses = Nuniverse.search(@input, :page => params[:page] || 1, :per_page => 10)
			end
	end

	
	def show
		redirect_to @nuniverse.redirect if @nuniverse.redirect
		@source = @nuniverse
		@nuniverses = @source.nuniverses.paginate(:page => params[:page] || 1, :per_page => 10)
		@facts = @source.facts.paginate(:page => params[:page] || 1, :per_page => 10)
		@bookmarks = @source.bookmarks.paginate(:page => params[:page] || 1, :per_page => 10)		
		@images = @source.images.paginate(:page => params[:page] || 1, :per_page => 10)		
		# # render :action => "edit" if !@nuniverse.active
		# 	
		# 	@connections = @connections.of_klass(@klass)
		# 	
		# 	@facts = @connections.of_klass(@facts).paginate(:page => 1, :per_page => 10)
		# 	if @klass
		# 	case params[:order]
		# 	when "by_latest"
		# 		@connections = @connections.order_by_date.with_score
		# 	when "by_name"
		# 		@connections = @connections.order_by_name.with_score
		# 	else
		# 		@connections = @connections.order_by_score(@perspective).with_score
		# 	end
		# 	
		# 	# @connections = @connections.relateds.of_klass(@klass)
		# 
		# 	if @context
		# 		@connections = @connections.sphinx(:per_page => 3000, :conditions => {:context_ids => @context.id})
		# 	end
		# 	if params[:filter]
		# 		@connections = @connections.sphinx(params[:filter], :per_page => 3000)
		# 	end
		# 	end
		# 	
		# 	@connections = @connections.paginate(:per_page => 20, :page => params[:page])
		
		respond_to do |f|
			f.html {
			
				@filter = params[:filter]  || nil
			}
			
			f.js {
				
			}
		end

	end
	
	def edit
		
		@nuniverse.update_with(params)
		redirect_to @nuniverse
	end
	
	def update
			@nuniverse.description = params[:nuniverse][:description]
			@tags = []
			params[:nuniverse][:tags].split(',').each do |t|
				@tags << Tag.find_or_create(:name => t.strip)
			end
			@nuniverse.tags = @tags
			@nuniverse.images << Image.new(params[:image]) rescue nil
			
			@nuniverse.bookmarks << Bookmark.new(:url => params[:bookmark][:url], :name => params[:bookmark][:url])
			
			@nuniverse.active = 1 if !@tags.empty?
			@nuniverse.save
			redirect_to @nuniverse
		# @taggings = []
		# 		params[:nuniverse][:tags].split(',').each do |t|
		# 			tag = Tag.find_or_create(:name => t.strip)
		# 			@taggings << Tagging.new(:taggable => @nuniverse, :tag => tag)
		# 		end
		# 		@nuniverse.taggings = @taggings
		# 		@nuniverse.save
		# 		redirect_back_or_default('/')
	end
	
	def destroy
		
		@nuniverse.destroy

    respond_to do |format|
      format.html { redirect_to user_url(current_user) }
      format.xml  { head :ok }
    end
		
	end
	
	def suggest
		@conditions = {} 
		
		if params[:input]
			tokens = Nuniversal.tokenize(params[:input])
			
			@suggestions = ThinkingSphinx::Search.search(:conditions => {:unique_name => tokens.last}, :with => {:active => 1 }, :classes => [User,Nuniverse], :order => "length ASC")
		else
			@conditions[:name] = @q
		end
		

		

		respond_to do |format|
			format.html {}
			format.js {}
		end
	end

	
	
	protected
	
	def find_nuniverse
		@source = @nuniverse = Nuniverse.find(params[:id])
	end

	
end

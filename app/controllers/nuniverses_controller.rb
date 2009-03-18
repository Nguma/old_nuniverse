class NuniversesController < ApplicationController
	
	before_filter :find_user, :only => [:suggest, :show, :command, :index]
	before_filter :make_token, :except => [:index, :suggest, :discuss]
	before_filter :find_source, :only => [:index]
	before_filter :update_session, :only => [:show]
 	after_filter :store_location, :store_source, :only => [:show]

	def index
			@input = params[:input].gsub('_',' ') rescue nil

			if @source
				@nuniverses = Nuniverse.search(@input, :page => params[:page] || 1, :per_page => 50)
			else
				@nuniverses = Nuniverse.search(@input, :page => params[:page] || 1, :per_page => 50)
			end
			
			respond_to do |f|
				f.html {}
				f.js {}
			end
	end

	
	def show
		
		redirect_to @namespace.redirect if @namespace.redirect			
		@path = @token.path
		
		@connections = @namespace.connections
		# @connections = Polyco
		if @path.last.name.match(/^review/)
			@connections = @connections.of_klass('Comment')	
		else
			@connections = @connections.sphinx(@path.to_s, :without => {:subject_id =>  @path.first.id}, :per_page => 3000, :page => 1)	
		end
		
		@connections = @connections.of_klass('Fact').with_score.order_by_score.paginate(:per_page => 15, :page => params[:page])
		
		@source = @token.path.first
		
		@comments = @namespace.comments.paginate(:page => 1, :per_page => 20)
		
	
		respond_to do |f|
			f.html {
			
				
				
			}
			
			f.js { 
				
				}
		end

	end
	
	def edit
		@scope = params[:scope][:type].classify.constantize.find(params[:scope][:id])
		# @nuniverse.update_with(params)
		# redirect_to @nuniverse
		
		respond_to do |f|
			f.html {}
			f.js {}
		end
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
	
	
	def new
		@collection = Collection.find(params[:collection_id])
		@nuniverse = Nuniverse.new
	end
	
	def create
		@nuniverse = Nuniverse.find(params[:nuniverse][:id]) rescue Nuniverse.create(params[:nuniverse])
		
		if params[:source]
			@object = params[:source][:type].classify.constantize.find(params[:source][:id])
			
			Polyco.create(:object => @object, :subject => @nuniverse, :state => 'active') rescue nil
		end		
		
	
		params[:properties].each do |p|
			t = Tag.find_by_name(p[0])
			@nuniverse.set_property(t,p[1]) 
		end
		

		
		respond_to do |f|
			f.js {}
			
		end
		
	end
	
	def destroy
		
		@nuniverse.destroy

    respond_to do |format|
      format.html { redirect_to user_url(current_user) }
      format.xml  { head :ok }
    end
		
	end
	
	def suggest
		
		@path = params[:value].split('/')
		@subject = @path.to_a.pop
		@tags = @path.join(' ')
	
		@suggestions = Nuniverse.search(@subject, :conditions => {:tags => @tags}, :page => 1, :per_page => 10)

		

		respond_to do |format|
			format.html {}
			format.js {
				
			}
		end
	end
	
	
	def discuss
		
	end

	
	
	protected
	


	
end

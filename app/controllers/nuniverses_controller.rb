class NuniversesController < ApplicationController
	
	before_filter :find_user, :only => [:suggest, :show, :command, :index]
	before_filter :find_nuniverse, :except => [:index, :suggest]
	before_filter :find_source, :only => [:index]
	before_filter :update_session, :only => [:show]
 	after_filter :store_location, :store_source, :only => [:show]

	def index
			@input = params[:input] rescue nil
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
		redirect_to @nuniverse.redirect if @nuniverse.redirect
		
		@nuniverses = @nuniverse.nuniverses.paginate(:page => params[:page] || 1, :per_page => 10)
		@facts = @nuniverse.facts.paginate(:page => params[:page] || 1, :per_page => 10)
		@bookmarks = @nuniverse.bookmarks.paginate(:page => params[:page] || 1, :per_page => 10)		
		@images = @nuniverse.images.paginate(:page => params[:page] || 1, :per_page => 10)		
		

		respond_to do |f|
			f.html {
				@source = @nuniverse
				if FileTest.exist?("#{LAYOUT_DIR}/#{@source.class.to_s}_#{@source.id}.xml")
					@boxes =	XMLObject.new(File.open("#{LAYOUT_DIR}/#{@source.class.to_s}_#{@source.id}.xml")).boxes rescue []
				else
					@boxes  = XMLObject.new(File.open("#{LAYOUT_DIR}/Template_#{@source.class.to_s}.xml")).boxes
				end
			}
			
			f.js { }
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
		@conditions = {} 
		
		if params[:input]
			tokens = Nuniversal.tokenize(params[:input])
			if tokens.empty?
				@suggestions =  ThinkingSphinx::Search.search(params[:input], :with => {:active => 1 }, :classes => [User,Nuniverse], :order => "length ASC")
			else
				@suggestions = ThinkingSphinx::Search.search(:conditions => {:unique_name => tokens.last}, :with => {:active => 1 }, :classes => [User,Nuniverse], :order => "length ASC")
			end
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
		if params[:id]
			@nuniverse = Nuniverse.find(params[:id]) 
		elsif params[:unique_name]
			@nuniverse = Nuniverse.find_by_unique_name(params[:unique_name])
		end
		@source = @nuniverse
	end

	
end

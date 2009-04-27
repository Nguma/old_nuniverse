class ImagesController < ApplicationController
	protect_from_forgery :except => [:upload]
	
	before_filter :make_token, :only => [:index]
	before_filter :find_source, :only => [:create]
	
	def index
		@source = Nuniverse.find_by_unique_name(params[:namespace])
		@images = @source.images.paginate(:page => params[:page], :per_page => 10)
		
	end
	
  def new
    @image = Image.new
  end
  
  def create

		@image = Image.find_or_create(:source_url => params[:command][:value], :uploaded_data => params[:command][:uploaded_data])
		if params[:command][:order].match(/goodface|badface|default/i)
			tag = Tag.find_by_name(params[:command][:order])
			@p = @source.connections.of_klass('Image').tagged(tag).first
			
			@p.tags.delete tag if @p
		end
		@source.add(@image, :tags => params[:command][:order])
		# @source.images << @image rescue nil
		
		respond_to do |f|
			f.html { render :layout => false}
			f.js { render :layout => false}
			f.json {}
		end
		
  end

	def disconnect
		if authorized?
			@source = Nuniverse.find_by_unique_name(params[:namespace])
			@image = Image.find_by_id(params[:id])
			@source.images.delete @image
		end
		
		respond_to do |f|
			f.html {redirect_back_or_default('/')}
			f.js { head :ok}
		end
	end
	
	
	def destroy
		@image = Image.find(params[:id])
		@image.destroy
		redirect_back_or_default('/')
	end
	
	def show
		@image = Image.find(params[:id])
		
		respond_to do |f|
			f.html {}
			f.js {
				render :action => :new if @image.nil?
			}
		end
	end
end
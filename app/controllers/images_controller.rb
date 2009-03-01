class ImagesController < ApplicationController
	protect_from_forgery :except => [:upload]
  def new
    @image = Image.new
  end
  
  def create
		@source = params[:source][:type].classify.constantize.find(params[:source][:id])
		@source = @source.is_a?(Polyco) ? @source.subject : @source
		begin
			@image = Image.create!(params[:image])
			@source.images << @image
		rescue
		end

		respond_to do |f|
			f.html { render :layout => false}
			f.js { render :layout => false}
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
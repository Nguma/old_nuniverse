class ImagesController < ApplicationController
	protect_from_forgery :except => [:upload]
  def new
    @image = Image.new
  end
  
  def create
	
    if @image = Image.create!(:source_url => params[:source_url].blank? ? nil : params[:source_url], :uploaded_data => params[:uploaded_data])
			@tag = @image.tag
			Connection.find_or_create(:object_id => params[:object], :subject_id => @image.tag_id)
			Connection.find_or_create(:subject_id => params[:object], :object_id => @image.tag_id)
		end
		
		respond_to do |f|
			f.html { redirect_back_or_default('/')}
			f.js {}
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
			f.js {}
		end
	end
end
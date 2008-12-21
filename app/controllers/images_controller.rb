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

	def upload
		@tag = Tag.create(
			:label => params[:Filename],
			:kind => 'image',
			:image => Image.new(:uploaded_data => params[:Filedata]),
			:description => '')
		if params[:path] && @tag
			subject = TaggingPath.new(params[:path]).last_tag
			Tagging.create(
				:subject_id => subject.id,
				:object_id => @tag.id,
				:path => params[:path],
				:user_id => params[:user_id]
			)
		end
		if subject.image.nil?
			subject.image = @tag.image
			subject.save
		end
			render :layout => false
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
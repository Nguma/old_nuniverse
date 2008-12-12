class ImagesController < ApplicationController
	protect_from_forgery :except => [:upload]
  def new
    @image = Image.new
  end
  
  def create
    if @image = Image.create!(:source_url => params[:source_url], :uploaded_data => params[:uploaded_data])
			@tag = @image.tag
			@image.tag.tag_with('image')
			@object = Tag.find(params[:object])
		
    	@tag.connect_with(@object)
		end
		
		respond_to do |f|
			f.html {}
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
		@tag = Tag.find(params[:id])
		@image =  Connection.with_subject(@tag).with_kind('image').first.object.image.public_filename

		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
end
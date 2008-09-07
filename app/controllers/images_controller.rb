class ImagesController < ApplicationController
	protect_from_forgery :except => [:upload]
  def new
    @image = Image.new
  end
  
  def create
    @image = Image.new params[:image] 
    @image.tag_id = params[:tag_id]
    
    if @image.save
      Image.find(:all, :conditions => {:tag_id => params[:tag_id]}).each do |av|
        av.destroy unless av.id == @image.id
      end
      
      redirect_to tag_path(@image.tag)
    else
      puts @image.errors.inspect
      render :action => "new"
    end
  end

	def upload
		@tag = Tag.create(
			:label => params[:Filename],
			:kind => 'image',
			:image => Image.new (:uploaded_data => params[:Filedata]),
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
	end
end
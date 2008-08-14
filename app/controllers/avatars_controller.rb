class AvatarsController < ApplicationController
	protect_from_forgery :except => [:upload]
  def new
    @avatar = Avatar.new
  end
  
  def create
    @avatar = Avatar.new params[:avatar] 
    @avatar.tag_id = params[:tag_id]
    
    if @avatar.save
      Avatar.find(:all, :conditions => {:tag_id => params[:tag_id]}).each do |av|
        av.destroy unless av.id == @avatar.id
      end
      
      redirect_to tag_path(@avatar.tag)
    else
      puts @avatar.errors.inspect
      render :action => "new"
    end
  end

	def upload
		@tag = Tag.create(
			:label => params[:Filename],
			:kind => 'image',
			:avatar => Avatar.new (:uploaded_data => params[:Filedata]),
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
		if subject.avatar.nil?
			subject.avatar = @tag.avatar
			subject.save
		end
			render :layout => false
	end
end

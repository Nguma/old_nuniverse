class AvatarsController < ApplicationController
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
end

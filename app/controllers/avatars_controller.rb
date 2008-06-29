class AvatarsController < ApplicationController
  def new
    @avatar = Avatar.new
  end
  
  def create
    @avatar = Avatar.new params[:avatar]
    if @avatar.save
      redirect_to @avatar.tag
    else
      render :action => "new"
    end
  end
end

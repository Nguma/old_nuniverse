class NuniverseController < ApplicationController
	
	def index
		redirect_to "/my_nuniverse" if logged_in?
	end
	
	def command
		@command = Command.new(current_user, params)
		if @command.argument
			@source =  List.new(:label => @command.argument, :creator => current_user, :tag_id => params[:tag] || nil)
			@subject = @source.tag if @source && @source.tag
		end
		if params[:tagging]
			@source = Tagging.find(params[:tagging])
			@subject = @source.object
		end
			
		@source = current_user if @source.nil?
		@subject = current_user.tag if @subject.nil?
		params[:source] = @source
		params[:subject] = @subject
		@result = @command.execute(params)	
		
		respond_to do |format|
			format.html {
				redirect_back_or_default(@source)
			}
			format.js {
				render :action => :property, :layout => false
			}	
		end
	end
	
	
end

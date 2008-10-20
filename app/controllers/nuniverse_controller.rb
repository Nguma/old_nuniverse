class NuniverseController < ApplicationController
	
	def index
		redirect_to "/my_nuniverse" if logged_in?
	end
	
	def command

		@command = Command.new(current_user, params)
		# if @command.argument
		# 		@source =  List.new(:label => @command.argument, :creator => current_user, :tag_id => params[:tag] || nil)
		# 		@subject = @source.tag if @source && @source.tag
		# 	end
		# 	if params[:tagging]
		# 		@source = Tagging.find(params[:tagging])
		# 		@subject = @source.object
		# 	end
			
		# @source = current_user if @source.nil?
		@subject = current_user.tag if @subject.nil?
		params[:source] = @source
		params[:subject] = @subject
		
		@result = @command.execute(params)	
		
		respond_to do |format|
			format.html {
				if @command.argument == "search"
					redirect_to @source
				else
					redirect_back_or_default(@source)
				end
			}
			format.js {
				render(:action => @command.action, :layout => false) 
				# render :action => :property, :layout => false
			}	
		end
	end
	
	def suggest
		@save_command = "add to #{params[:context] || ""}".gsub(' ', '_')
		@input = params[:input]
		if params[:command].downcase == "add address"
			render :action => "google_locations" if @input
		else
			@command = Command.new(current_user, params)
			@input = @command.input	
			@items = @command.search_results(:page => params[:page], :per_page => 5)	
		end
	end
	
end

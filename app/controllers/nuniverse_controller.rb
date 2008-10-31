class NuniverseController < ApplicationController
	
	def index
		redirect_to "/my_nuniverse" if logged_in?
	end
	
	def command

		params[:service] ||= "everyone" 
		@command = Command.new(current_user, params)
		@source = @command.list
		@kind = @command.kind
		@result = @command.execute(params)	

		respond_to do |format|
			format.html {
				if @command.action == "find"
					redirect_to "/my_nuniverse/all/#{params[:input]}"
				else
					redirect_back_or_default("/")
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
		if params[:command].downcase == "find address"
			@source = Tag.find(params[:tag_id])
			render(:action => "google_locations", :layout => false) if @input
		else
			@command = Command.new(current_user, params)
			@input = @command.input	
			@kind = @command.kind
			@items = @command.search_results(:page => params[:page], :per_page => 5)	
		end
	end
	
end

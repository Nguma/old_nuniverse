class NuniverseController < ApplicationController
	
	def index
		redirect_to "/my_nuniverse" if logged_in?
	end
	
	def ask
		gums = Gum.parse(params[:query])
		unless gums.empty?
			@kind = Nuniverse::Kind.match(gums[0][1]).strip
			params[:query] = gums[0][2]
		end
		case @kind
			when "address","tel","zip"
				@subject.replace_property(@kind, params[:query])
				@subject.save
			when "image"
				@subject.add_image(:source_url => params[:query])
			when "description"
				@tagging.description = params[:query]
				@tagging.save
			when "invite"
				@user = User.find_by_email(params[:query]) || User.create(:email => params[:query])
				current_user.invite(:user => @user, :topic => @tagging)
			when "list"
		end
	end
	
	
end

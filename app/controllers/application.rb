# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
	include AuthenticatedSystem
	
	before_filter :invitation_required, :except => [:beta]

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  :secret => '6d0fa0cfa575daf50a50a8c4f23265a5'

	def restricted
		
	end
	
	def beta
		
	end
	

	protected
	def invitation_required
		if !logged_in?
			redirect_to "/beta"
		end
	end
	

end

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
	include AuthenticatedSystem
	
	before_filter :invitation_required, :except => [:beta, :feedback, :thank_you, :about, :screenshots]

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  :secret => '6d0fa0cfa575daf50a50a8c4f23265a5'

	def restricted
		
	end
	
	def about
	end
	
	def beta
	end
	
	def thank_you
	end
	
	def screenshots
	end
	
	def feedback
		if params[:feedback]
			@selected = "feedback"
			UserMailer.deliver_feedback(:ip => request.remote_ip, :user => current_user || nil, :feedback => params[:feedback])
			render :action =>  "thank_you"
		end
	end
	
	def method_missing
		raise "METHOD MISSING!!!"
	end
	
	def redirect_to_default
		raise "DEFAULT"
	end
	

	protected
	def invitation_required
		if !logged_in?
			redirect_to "/beta"
		end
	end
	
	def update_session
		session[:mode] = @mode
		session[:service] = @service
		session[:perspective] = @perspective
		session[:kind] = @kind
		if @tag	
			session[:previous] = session[:current] unless session[:current] == @tag.id
			session[:current] = @tag.id
	
		else
			session[:tag] = nil
			session[:current] = nil
		end
	end
	
	def find_user
		if !params[:user] || ["you","me"].include?(params[:user])
			@user = current_user
		else
			@user = User.find_by_login(params[:user]) || current_user
		end
	end
	
	
	def find_everyone
		@everyone = User.find(0)
	end
	
	def find_perspective		
		if params[:perspective]
			@perspective = Tag.find(:first, :conditions => ['label = ? AND kind in (?)', params[:perspective], ['user','group','service']])
			
		else
			@perspective = !session[:perspective].nil? ?  session[:perspective] : current_user.tag
		end
		@perspective = current_user.tag if @perspective.nil?
		@perspective
	end
	
	def service_items(query)
		
		case @perspective.label
		when "google"
			
			Googleizer::Request.new(query.gsub('&','and') , :mode => "web").response.results
		when "amazon"
			Finder::Search.find(:query => query, :service => 'amazon')
		when "youtube"
			Googleizer::Request.new(query.gsub('&','and') , :mode => "video").response.results
		when "twitter"
			Finder::Search.find(:query => query, :service => 'twitter')
		else
			
		end
	end

end

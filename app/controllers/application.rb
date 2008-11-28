# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
	include AuthenticatedSystem
	
	before_filter :invitation_required, :except => [:beta, :feedback, :thank_you, :about]

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
			@perspective = Perspective.find(:first, :conditions => ['tags.label = ?', params[:perspective]], :include => :tag)
			@perspective = current_user.self_perspective if @perspective.nil?
	
		else
			@perspective = !session[:perspective].nil? ?  session[:perspective] : current_user.self_perspective
		end
		# Last line is to replace 'default' user for common perspectives, such as 'everyone'
		@perspective.user = current_user 
	end
	
	def service_items(query)
		
		case @perspective.tag.label
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

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
	include AuthenticatedSystem
	
	
	before_filter :invitation_required, :except => [:beta, :feedback, :thank_you, :about, :screenshots]


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  :secret => '6d0fa0cfa575daf50a50a8c4f23265a5'

	def index
		if logged_in?
			redirect_to current_user
		else
			redirect_to :beta
		end
	end

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
		@display = session[:display] = params[:display] ? params[:display] : (!session[:display].nil? ? session[:display] : "cards")
		@order = session[:order] = params[:order] ? params[:order] : (!session[:order].nil? ? session[:order] : "by_latest")
		# @klass = session[:klass] = params[:klass] ? params[:klass] : (!session[:klass].nil? ? session[:klass] : "Nuniverse")
		@klass = params[:klass]
		
		@size = (@display == "image") ? :large : :small
		
		session[:service] = @service
		session[:perspective] = @perspective

		
		session[:last_input] = @filter
	
	end
	
	def find_user
		if !params[:user] || ["you","me"].include?(params[:user])
			@user = current_user
		else
			@user = User.find_by_login(params[:user]) || current_user
		end
	end
	
	def find_context
		
		@context = params[:context][:type].classify.constantize.find(params[:context][:id])  rescue nil
	
	end

	def service_items(query)
		
		case @perspective.name
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
	
	def connect_to_object(subject)
		return nil if !params[:object]
		@object = params[:object][:type].classify.constantize.find(params[:object][:id])
		Polyco.create(:subject => subject, :object => @object, :state => 'active') unless @object.nil?
	end
	
	
	def wikipedit(bookmark)
		urlscan = bookmark.scan(/((https?:\/\/)?[a-z0-9\-\_]+\.{1}([a-z0-9\-\_]+\.[a-z]{2,5})\S*)/ix)[0]
		
		doc = Hpricot open bookmark
		
		if urlscan[2] == "wikipedia.org"
			@lat = (doc/"span[@class=geo-default]"/"span[@class=latitude]").first.inner_html
			@lng = (doc/"span[@class=geo-default]"/"span[@class=latitude]").first.inner_html
			@description = (doc/"#bodyContent"/:p)[1].inner_html
			raise @description.inspect
		else
			return Bookmark.new(:name => bookmark, :url => bookmark)
		end
	end

end

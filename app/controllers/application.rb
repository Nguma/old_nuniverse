# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
	include AuthenticatedSystem
	include Nuniversal
	
	

	
	before_filter :find_source, :only => [:save_layout]


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  :secret => '6d0fa0cfa575daf50a50a8c4f23265a5'

	def index

		@rankings = Ranking.find(:all, :conditions => "rankable_type = 'Nuniverse'", :group => "rankable_id, rankable_type", :order => "updated_at DESC").paginate(:page => params[:page], :per_page => 20, :order => "updated_at desc" )
		respond_to do |f|
			f.html {}
			f.js {}
			f.json {render :json => {:rankings => @rankings}}
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
	
	def save_layout
		find_context
			save_page("#{@context.class.to_s}_#{@context.id}")
		respond_to do |f|
			f.xml {head :ok}
		end
	end
	

	protected
	def invitation_required
		if !logged_in?
			redirect_to "/"
		end
	end
	
	def update_session
		@display = session[:display] = params[:display] ? params[:display] : (!session[:display].nil? ? session[:display] : "cards")
		@order = session[:order] = params[:order] ? params[:order] : (!session[:order].nil? ? session[:order] : "by_latest")
		# @klass = session[:klass] = params[:klass] ? params[:klass] : (!session[:klass].nil? ? session[:klass] : "Nuniverse")
		@klass = params[:klass]
		session[:size] = (@display == "image") ? :large : :small
		session[:last_input] = @filter
	end
	
	def find_user
		if !params[:user] || ["you","me"].include?(params[:user])
			@user = current_user
		else
			@user = User.find_by_login(params[:user]) || current_user
		end
	end
	
	def store_source
		session[:source] = @source
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
	
	def find_source
	  @source = params[:source][:type].classify.constantize.find(params[:source][:id])
	end
	
	def find_context
		context_id = params[:context_id] || params["#{ params[:context_type] }_id"]
		@context = 	params[:context_type].classify.constantize.find(context_id)
	end
	
	def make_token
		if params[:path]
			@path = params[:path]
			@token = Token.new("/#{@path.join('/')}/")
	
			@namespace = @token.namespace
		end
	end
	


end

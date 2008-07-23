class TaggingsController < ApplicationController

	def index
		@connections = Tagging.paginate(:all, :order => "created_at DESC", :page => 1, :per_page => 20)
	end
	
	def create
		gumies = params[:content].scan(/\s*#([\w_]+)[\s]+([^#|\[|\]]+)*/)
		gum = {}
		unless gumies.empty?
			params[:content] = gumies[0][1]
			params[:kind]    = gumies[0][0]
			
			gumies.each do |gumi|
				gum[gumi[0]] = gumi[1]
			end
		end
		
		params[:description] ||= gum.delete('description')
		params[:url]         ||= gum.delete('url')
		params[:service]     ||= gum.delete('service')
		
		@tagging = Tag.connect(
			:content 	    => params[:content],
			:kind			    => params[:kind],
			:path			    => params[:path],
			:restricted   => params[:restricted],
			:description  => params[:description],
			:url          => params[:url],
			:service      => params[:service],
			:data         => gum.collect { |k,v| "##{k} #{v}" }.join(" ")
			:user_id	    => current_user.id
		)
		
    respond_to do |format|
      flash[:notice] = 'Connection was successfully created.'
      format.html { render :layout => false }
      format.xml  { render :xml => @tag, :status => :created, :location => @tag  }
    end
	end
end
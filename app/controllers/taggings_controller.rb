class TaggingsController < ApplicationController

	def index
		@connections = Tagging.paginate(:all, :order => "created_at DESC", :page => 1, :per_page => 20)
	end
	
	def create
		
		if params[:id]
			@tagging = Tagging.create Tagging.find(params[:id]).attributes.merge(
				:user_id => current_user.id,
				:path		 => params[:path]
			)
		else
			gumies = params[:content].scan(/\s*#([\w_]+)[\s]+([^#|\[|\]]+)*/)
			gum = {}
			unless gumies.empty?
				params[:content] = gumies[0][1]
				params[:kind]    = gumies[0][0]
				gumies.shift
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
				:description  => params[:description] || "",
				:url          => params[:url],
				:service      => params[:service],
				:data         => gum.collect { |k,v| "##{k} #{v}" }.join(" "),
				:user_id	    => current_user.id
			)
		end
		
    respond_to do |format|
      flash[:notice] = 'Connection was successfully created.'
      format.html { render :layout => false }
      format.xml  { render :xml => @tag, :status => :created, :location => @tag  }
    end
	end
	
	def delete
		@tagging = Tagging.find(params[:id])
		raise "You don't have the right to do this!" if current_user != @tagging.user
		@tagging.destroy
		render :nothing => true
	end
end
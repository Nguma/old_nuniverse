class TaggingsController < ApplicationController

	def index
		@connections = Tagging.paginate(:all, :order => "created_at DESC", :page => 1, :per_page => 20)
	end
	
	def create
		gumies = params[:content].scan(/\s*#([\w_]+)[\s]+([^#|\[|\]]+)*/)
		gum = {}
		unless gumies.empty?
			params[:content] = gumies[0][1]
			params[:kind] = gumies[0][0]
			
			gumies.each do |gumi|
				gum[gumi[0]] = gumi[1]
			end
		end
		
		@tagging = Tag.connect(
			:content 	=> params[:content],
			:kind			=> params[:kind],
			:path			=> params[:path],
			:restricted => params[:restricted],
			:description => gum['description'] || params[:description],
			:url => gum['url'] || nil,
			:user_id	=> current_user.id
		)
		
    respond_to do |format|
        flash[:notice] = 'Connection was successfully created.'
        format.html { render :layout => false }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag  }
    end
	end
	
end
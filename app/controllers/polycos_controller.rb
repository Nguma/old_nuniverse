class PolycosController < ApplicationController

	
	before_filter :find_polyco, :except => [:index, :new, :create, :suggest, :make_connection]
	before_filter :find_source, :only => [:new, :create, :make_connection]

	before_filter :update_session
	after_filter :store_location, :only => [:show]
	
	def index
	
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def show
		if params[:collection_id]
			@collection = Collection.find(params[:collection_id])
		else
			@collection = @polyco.subject.contexts.find(:first, :conditions => {:parent_id => @polyco.object.id, :parent_type => @polyco.object.class.to_s})
		end
		@source = @polyco.object
	end
	
	def rate
		@ranking = @polyco.rankings.by_user(current_user).first || Ranking.new(:user => current_user)
		@polyco.rankings << @ranking

		@ranking.score = params[:score].to_i
		@ranking.save
		redirect_back_or_default("/")
	end
	
	def make_connection

		# @object = params[:object_type].classify.constantize.find(params[:object_id])
		tokens = params[:command][:value].scan(/#(\w+)/).flatten.reject {|c| c.blank? }
		label = params[:command][:value].scan(/^(\w+)\:/).flatten.reject {|t| t.blank? }.to_s
		@tag = Tag.find_or_create(:name => label) unless label.blank?
		body =  params[:command][:value].gsub(/^#{label}\:/, '')
		tokens.each do |t|
			subject = Nuniverse.find_or_create(:unique_name => t)
			@polyco = Polyco.find_or_create(:subject => subject, :object => @source, :description => params[:command][:value])
			body = body.gsub(/\##{t}/,'')
		end
		
		
		if !body.blank?
			@fact =  Fact.create(:parent_id => @source.id, :parent_type => @source.class.to_s, :body => params[:command][:value], :author_id => current_user)
			@source.facts << @fact rescue nil
		end
		if @fact && @tag
			@fact.tags << @tag
		elsif @tag
			@polyco.tags << @tag
		end
		# @subject = Nuniverse.find_by_unique_name(value)
		
		unless @source.nil? || @subject.nil?
			
			flash[:notice] = "#{@subject.name} was connected to #{@source.name}"
		else
			flash[:error] = "There was some error creating that connection"
		end

		respond_to do |f|
			f.js {}
		end
	end
	
	def edit
	end
	
	def update
		@subject = @polyco.subject
		
		params[:properties].each do |p|
			t = Tag.find_by_name(p[0])
			@subject.set_property(t,p[1]) 
		end
		
		respond_to do |f|
			f.html {}
			f.js { render :action => "show"}
		end
				
	end

	def connect
		@command = Command.new(:commander => current_user, :order => params[:command][:order], :value => params[:command][:value])
		# @order => Nuniverse.find()
	end
	
	def create
		@command = Command.new(:commander => current_user, :order => params[:command][:order], :value => params[:command][:value])
		if @command.order == "pro"
			
		elsif @command.order == "con"
		
		else
			
		
		@token = Token.new("/#{@source.unique_name}/#{@command.order}/#{@command.value}", :current_user => current_user)

		if @token
		 	if !@token.images.empty?
				@new = @token.images.first
			elsif !@token.bookmarks.empty?
				@new = @token.bookmarks.first
			elsif @token.value.is_a?(Comment)
				@source.comments << @token.value
				@new = @token.value
			elsif @token.value
				@source.nuniverses << @token.value rescue nil
				@new = @token.value
			elsif !@token.body.blank?
				@source.facts << @fact 
				@new = @fact
			end
			
			if @new
				@connection = @source.connections.with_subject(@new).first
				@connection.tags << @token.tags rescue nil
			end

			@tag = nil
		end
		end
		
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def new
		@collection = Collection.find(params[:collection_id])
		@context = @collection.parent
		@subject = Nuniverse.find(params[:subject_id]) rescue nil
		@polyco = Polyco.new(:object => @context, :subject => @subject)
		
	end
	
	
	def destroy
		@object = @polyco.object
		@polyco.subject.destroy if @polyco.subject.active == 0
		@polyco.destroy
		redirect_back_or_default('/')
	end
	
	
	def suggest
		
		# @object = params[:object][:type].classify.constantize.find(params[:object][:id])
		value = params[:command][:value].scan(/\#([\w\_]+)/).flatten.last
	
		@suggestions = Nuniverse.search("#{value}*")
		respond_to do |format|
			format.html {}
			format.js {}
		end
	end
	
	protected
	
	def find_polyco
		
		@polyco = @source = Polyco.find(params[:id]) 
	end
end
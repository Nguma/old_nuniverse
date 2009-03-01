class PolycosController < ApplicationController

	
	before_filter :find_polyco, :except => [:index, :new, :create, :connect, :suggest]
	before_filter :find_context, :only => [:show, :new]
	before_filter :find_context, :only => [:create, :connect]
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
		# @suggestions = Nuniverse.search( :match_mode => :extended, :conditions => {:name => @polyco.subject.name, :active => 1}, :per_page => 10)
		# @source = @polyco
		
	end
	
	def rate
		@ranking = @polyco.rankings.by_user(current_user).first || Ranking.new(:user => current_user)
		@polyco.rankings << @ranking

		@ranking.score = params[:score].to_i
		@ranking.save
		redirect_back_or_default("/")
	end
	
	def connect
		@object = params[:object_type].classify.constantize.find(params[:object_id])
		@subject = params[:subject_type].classify.constantize.find(params[:subject_id])
		
	
		
		unless @object.nil? || @subject.nil?
			@polyco = Polyco.find_or_create(:subject => @subject, :object => @object,:state => "active")
			
			@polyco.save_all
			flash[:notice] = "#{@subject.name} was connected to #{@object.name}"
		else
			flash[:error] = "There was some error creating that connection"
		end

		
		
		redirect_back_or_default('/')
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

	
	def create
		@object = params[:object][:type].classify.constantize.find(params[:object][:id])
		@subject =  params[:subject][:type].classify.constantize.find(params[:subject][:id]) 

			
		@polyco = Polyco.new(params[:polyco])
		@polyco.object = @object
		@polyco.subject = @subject
		@polyco.state = "active" if @polyco.subject.active
		

		@polyco.subject.contexts << @context if @context
		
    respond_to do |format|
      if @polyco.save_all
        flash[:notice] = 'Story was successfully created.'
				
        format.html { 
	redirect_back_or_default("/")
			
				}
        format.xml  { render :xml => @story, :status => :created, :location => @story }
      else
	 			flash[:notice] = 'Blaaaa eeee nooo connection.'
        format.html { 	redirect_back_or_default("/")}
        format.xml  { render :xml => @story.errors, :status => :unprocessable_entity }
      end
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
		@polyco.twin.destroy rescue nil
		@polyco.destroy
		redirect_back_or_default('/')
	end
	
	
	def suggest
		
		@object = params[:object][:type].classify.constantize.find(params[:object][:id])
		@suggestions = ThinkingSphinx::Search.search(:conditions => {:name => "#{params[:subject][:name]}"}, :with => {:active => 1}, :classes => [User,Nuniverse])
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
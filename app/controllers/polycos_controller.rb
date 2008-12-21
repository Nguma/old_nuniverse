class PolycosController < ApplicationController

	
	before_filter :find_polyco, :except => [:index, :new, :create, :connect]
	before_filter :update_session
	after_filter :store_location, :only => [:show]
	
	def index
		@polycos = Polyco.order_by_date.exclude_twins.paginate(:page => 1, :per_page => 78)
	end
	
	def show
		redirect_to @polyco.object if @polyco.state == "active"
		@suggestions = Nuniverse.search @polyco.subject.name, :match_mode => :extended, :conditions => {:state => 1}, :per_page => 10 unless params[:no_suggestions]
		@source = @polyco
	
	end
	
	def rate
		@ranking = @polyco.rankings.by_user(current_user).first || Ranking.new(:user => current_user)
		@polyco.rankings << @ranking

		@ranking.score = params[:score].to_i
		@ranking.save
		redirect_back_or_default("/")
	end
	
	def connect
		@polyco = Polyco.new(:subject_type => params[:subject_type].capitalize , :subject_id => params[:subject_id], :object_type => params[:object_type].capitalize, :object_id => params[:object_id], :state => "active")
		@polyco.save rescue nil
		
		@polyco.twin.state = "active"
		@polyco.twin.save
		
		
		redirect_back_or_default('/')
	end
	
	def edit
	end
	
	def update
		
		
		if params[:subject_id] 

			@polyco.subject.delete
			@polyco.subject = params[:subject_type].classify.constantize.find(params[:subject_id])

		end
		if params[:polyco]	
			if @polyco.subject.is_a?(Tag)
				@polyco.subject = Nuniverse.new(:name => @polyco.subject.name)
			end
			@polyco.description = params[:polyco][:description] 
			if params[:subject]
				@polyco.subject.description = params[:subject][:description]
			end
			
			@polyco.subject.state = 1 if @polyco.is_a?(Nuniverse)
			
			if params[:image]
				@polyco.subject.images << Image.create(params[:image])
			end
		end
		@polyco.state = params[:state] || "active"
		@polyco.save_all

		redirect_back_or_default("/")
		
	end
	
	def create

		redirect_to eval "#{@klass.downcase.pluralize}_url" if params[:submit] == "Visit"
		@polyco = Polyco.new(params[:polyco])

		@polyco.state = "active" if @polyco.subject

		@polyco.subject ||= @klass.classify.constantize.create(params[:subject])

    respond_to do |format|
      if @polyco.save_all
        # flash[:notice] = 'Story was successfully created.'
				
        format.html { 
						if ["User","Nuniverse"].include?(@klass)
							redirect_to @polyco
						else
							redirect_back_or_default("/")
						end
				}
        format.xml  { render :xml => @story, :status => :created, :location => @story }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @story.errors, :status => :unprocessable_entity }
      end
    end
	end
	
	def new
		@source = current_user
		@polyco = Polyco.new(:object => current_user)
	end
	
	
	def destroy
		@object = @polyco.object
		@polyco.subject.destroy if @polyco.subject.state == "pending"
		@polyco.twin.destroy 
		@polyco.destroy
		redirect_to @object
	end
	
	protected
	
	def find_polyco
		@polyco = @source = Polyco.find(params[:id])
	end
end
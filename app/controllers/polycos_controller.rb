class PolycosController < ApplicationController

	
	before_filter :find_polyco, :except => [:index, :new, :create, :connect, :suggest]
	before_filter :find_context, :only => [:create, :update, :connect]
	before_filter :update_session
	after_filter :store_location, :only => [:show]
	
	def index
		@polycos = Polyco.order_by_date.exclude_twins.paginate(:page => 1, :per_page => 78)
	end
	
	def show
		redirect_to @polyco.object if @polyco.state == "active"
		# raise Nuniverse.search( :match_mode => :extended, :conditions => {:name => @polyco.subject.name, :active => 1}, :per_page => 10).inspect
		@suggestions = Nuniverse.search( :match_mode => :extended, :conditions => {:name => @polyco.subject.name, :active => 1}, :per_page => 10)
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
		

		if params[:subject_id] 

			@polyco.subject.delete
			@polyco.subject = params[:subject_type].classify.constantize.find(params[:subject_id])
				@polyco.subject.active = 1
				@polyco.subject.save
		end

		if params[:polyco]	
			if @polyco.subject.is_a?(Tag)
				@polyco.subject = Nuniverse.new(:name => @polyco.subject.name)
			end
			@polyco.description = params[:polyco][:description] 
			
			if params[:subject]
				if params[:subject][:description]
				@polyco.subject.description = params[:subject][:description]
				params[:subject][:description].split(',').each do |t|
						tag = Tag.find_or_create(:name => t.strip) 
						@polyco.subject.taggings << Tagging.new(:taggable => @polyco.subject, :tag => tag) unless tag.name.nil?
				end
			end
			end
			@polyco.subject.active = 1
			@polyco.subject.save
			
			
			if params[:image] && (!params[:image][:source_url].blank?)
				begin
					@polyco.subject.images << Image.create(params[:image])
				rescue
					
				end
			end
		end
		
		@polyco.save_all

		respond_to do |f|
				f.html { 
					if params[:subject_id] 
						redirect_to edit_polyco_url(@polyco)
					else 
						redirect_back_or_default("/")
					end
				}
		end
		
		
		
	end

	
	def create
		@object = params[:object][:type].classify.constantize.find(params[:object][:id])
		@subject =  params[:subject][:type].classify.constantize.find(params[:subject][:id]) rescue @klass.classify.constantize.create!(params[:subject])
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
		@source = current_user
		@polyco = Polyco.new(:object => current_user)
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
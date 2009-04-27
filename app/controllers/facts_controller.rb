class FactsController < ApplicationController
	
	after_filter :store_location, :only => [:show]
	before_filter :find_source, :only => [:index]
  # GET /facts
  # GET /facts.xml
  def index
    @input = params[:input]
		if !@source
			@facts = Fact.search(@input, :with => {:nuniverse_ids => @source.id}, :page => params[:page] || 1, :per_page => 10)
		else
			@facts = Fact.search(@input, :page => params[:page] || 1, :per_page => 10)
		end


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @facts }
    end
  end

  # GET /facts/1
  # GET /facts/1.xml
  def show
    @fact = Fact.find(params[:id])
	
		if params[:vote]
			@vote = @fact.rankings.by(current_user).first
			@vote = Ranking.new(:rankable_id => @fact.id, :rankable_type => 'Fact', :user => current_user) if @vote.nil?
			@vote.score = params[:vote]
			@vote.save
		end

		@facts = @fact.facts.paginate(:page => params[:page], :per_page => 10, :order => "created_at DESC")
	
		@namespace = @fact
		# @suggestions = Nuniverse.search( @fact.body, :match_mode => :any)

    respond_to do |format|
      format.html {
				@source = @fact
			}# show.html.erb
			format.js {}
      format.xml  { render :xml => @fact }
    end
  end

  # GET /facts/new
  # GET /facts/new.xml
  def new
    @fact = Fact.new

    respond_to do |format|
      format.html # new.html.erb
			format.js {}
      format.xml  { render :xml => @fact }
    end
  end

  # GET /facts/1/edit
  def edit
    @fact = Fact.find(params[:id])
		respond_to do |f|
			f.html {}
			f.js {}
		end
  end

  # POST /facts
  # POST /facts.xml
  def create
    @fact = Fact.new(params[:fact])

		@source = params[:source][:type].classify.constantize.find(params[:source][:id]) rescue  current_user
		@fact.author = current_user
		@fact.parent = @source
		@fact.body = @fact.body_without_category
		@path = params[:path]
		
		@namespace = @source
		unless params[:fact][:body].blank?
			body = params[:fact][:body]
			body = ":#{body}" unless body.match(':')
			str = "#{@path}#{body}" 
		end
	
		
		@token = Token.new(str, :current_user => current_user)
	
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
    respond_to do |format|


        format.html { 
					flash[:notice] = 'Fact was successfully created.'
					redirect_to polymorphic_url(@source) 
				}
				format.js {
					head 500 if @token.nil?
				}
        format.xml  { render :xml => @fact, :status => :created, :location => @fact }

    end
  end

  # PUT /facts/1
  # PUT /facts/1.xml
  def update
    @fact = Fact.find(params[:id])
		@scan = params[:fact][:body].scan(/^(([\w\-]+)\:)?(.*)/)[0]
		@fact.body = @scan[2].strip
			@tokens = Nuniversal.tokenize(@fact.body)
			
			@tokens.each do |token|
				
				n = Nuniverse.find_or_create(token)
				unless n.nil?
					@fact.subjects << n rescue nil
				end
			end
		@fact.tags = [Tag.find_or_create(:name => @scan[1].downcase)] rescue []

	
    respond_to do |format|
      if @fact.save
        flash[:notice] = 'Fact was successfully updated.'
        format.html { redirect_back_or_default("/")}
				format.js {}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
				format.js {}
        format.xml  { render :xml => @fact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /facts/1
  # DELETE /facts/1.xml
  def destroy
    @fact = Fact.find(params[:id])
		@parent = @fact.parent
    @fact.destroy

    respond_to do |format|
      format.html { redirect_to "/nuniverse-of/#{@parent.unique_name}" }
      format.xml  { head :ok }
    end
  end
end

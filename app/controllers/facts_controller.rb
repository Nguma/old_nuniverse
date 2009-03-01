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
		@tag = Tag.find_by_name(params[:tag_name])
		@facts = @fact.connections.tagged(@tag).paginate(:page => params[:page], :per_page => 10, :order => "created_at DESC")
	

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
	
		# @fact.body = @scan[2].strip
		# @fact.tags = [Tag.find_or_create(:name => @scan[1])]
		@source = params[:source][:type].classify.constantize.find(params[:source][:id]) rescue  current_user
		

    respond_to do |format|
      if @fact.save
				
				if contains_url?(@fact.body) 			
					url = scan_url(@fact.body_without_category)
					
					@fact.bookmarks << parse_url(url[0])
				end
				# @tokens = Nuniversal.tokenize(@fact.body)
				# 			@tokens.each do |token|
				# 				n = Nuniverse.find_or_create(token)
				# 				
				# 				@fact.subjects << n unless n.nil?
				# 			end
				@fact.tags << Tag.find_or_create(:name => @fact.category) if @fact.category 
				@source.facts << @fact
				# if @scan[1] == "address"
				# 				@source.locations << Nuniversal.localize(@fact.body, @source) rescue nil
				# 			end
        
        format.html { 
					flash[:notice] = 'Fact was successfully created.'
					redirect_to polymorphic_url(@source) 
				}
				format.js {
					
				}
        format.xml  { render :xml => @fact, :status => :created, :location => @fact }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fact.errors, :status => :unprocessable_entity }
      end
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
    @fact.destroy

    respond_to do |format|
      format.html { redirect_back_or_default('/') }
      format.xml  { head :ok }
    end
  end
end

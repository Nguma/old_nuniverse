class RankingsController < ApplicationController
  # GET /rankings
  # GET /rankings.xml
  def index
    @rankings = Rankings.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rankings }
    end
  end

  # GET /rankings/1
  # GET /rankings/1.xml
  def show
    @rankings = Rankings.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rankings }
    end
  end

  # GET /rankings/new
  # GET /rankings/new.xml
  def new
    @rankings = Rankings.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rankings }
    end
  end

  # GET /rankings/1/edit
  def edit
    @rankings = Rankings.find(params[:id])
  end

  # POST /rankings
  # POST /rankings.xml
	# POST /rankings.json
  def create
		
		@score = params[:score].to_i.round
		@namespace = Nuniverse.find_by_unique_name(params[:namespace])
		@ranking = Ranking.find_or_create(:user_id => current_user.id, :score => @score, :rankable_id => @namespace.id,  :rankable_type => @namespace.class.to_s)
		
    respond_to do |format|
      if @ranking.save
        flash[:notice] = 'Rankings was successfully created.'
        format.html { redirect_to(@ranking) }
				format.js		{ }
				format.json { 
					sc = @namespace.total_score
					render :json => {'user' => current_user.login,'color' => @ranking.color, 'score' => sc, 'score_label' => Ranking.label(@namespace.score),'vote' => @ranking, 'stats' => @namespace.stats}
				}
        format.xml  { render :xml => @ranking, :status => :created, :location => @ranking }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ranking.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rankings/1
  # PUT /rankings/1.xml
  def update
    @rankings = Rankings.find(params[:id])

    respond_to do |format|
      if @rankings.update_attributes(params[:rankings])
        flash[:notice] = 'Rankings was successfully updated.'
        format.html { redirect_to(@rankings) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rankings.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rankings/1
  # DELETE /rankings/1.xml
  def destroy
    @rankings = Rankings.find(params[:id])
    @rankings.destroy

    respond_to do |format|
      format.html { redirect_to(rankings_url) }
      format.xml  { head :ok }
    end
  end
end

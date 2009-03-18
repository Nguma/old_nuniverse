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
  def create
		
		@score = params[:rate].scan(/\d+/).to_s.to_i.round
		@ranking = Ranking.find_or_create(:user_id => current_user.id, :score => @score, :rankable_id => params[:source][:id] , :rankable_type => params[:source][:type])

    respond_to do |format|
      if @rankings.save
        flash[:notice] = 'Rankings was successfully created.'
        format.html { redirect_to(@rankings) }
				format.js		{ }
        format.xml  { render :xml => @rankings, :status => :created, :location => @rankings }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rankings.errors, :status => :unprocessable_entity }
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

class NuniversesController < ApplicationController
	
	before_filter :find_user, :only => [:suggest, :show, :command, :index]
	before_filter :make_token, :except => [:index, :suggest, :discuss]
	# before_filter :find_source, :only => [:index]
	before_filter :update_session, :only => [:show]
 	after_filter :store_location, :store_source, :only => [:show]

	def index
		
		@nuniverses = Nuniverse.find(:all, :conditions => ['name rlike ? OR unique_name rlike ?', params[:input], params[:input].gsub(' ','_')]).paginate(:page => params[:page], :per_page => 20)
		json = []
		@nuniverses.each do |n|
			json << n.to_json
			json.last['url'] = "/wdyto/#{n.unique_name}"
		end
		
		@new_nuniverse = Nuniverse.new(:name => params[:input], :unique_name => Token.sanatize(params[:input]))
		
		respond_to do |f|
			f.html {}
			f.js {}
			f.json { render :json => {:results => json}}
		end
	end
	
	
	def wdyto
		@namespace = Nuniverse.find_by_unique_name(params[:namespace])
		@source = @namespace
		@comments = @namespace.comments
		@current_user_vote = @source.votes.by(current_user).first
		@votes = @source.votes.paginate(:page => params[:page], :per_page => 20)
		@connections = @source.connections.of_klass('Nuniverse').paginate(:page => 1, :per_page => params[:page])
		
		@prosandcons = @source.connections.of_klass('Tag').paginate(:page => 1, :per_page => params[:page])
	end
	
	def create
		@nuniverse = Nuniverse.create(params[:nuniverse])
		respond_to do |f|
			f.html {redirect_to "/wdyto/#{@nuniverse.unique_name}"}
		end
	end

	
	def show
		
		redirect_to @namespace.redirect if @namespace.redirect			
		@path = @token.path
		
		@connections = @namespace.connections
		# @connections = Polyco
		if @path.last.name.match(/^review/)
			@connections = @connections.of_klass('Comment')	
		else
			@connections = @connections.sphinx(@path.to_s, :without => {:subject_id =>  @path.first.id}, :per_page => 3000, :page => 1)	
		end
		
		@connections = @connections.of_klass('Nuniverse').with_score.order_by_score.paginate(:per_page => 3, :page => params[:page])
		@media = @namespace.connections.of_klass(['Image', 'Video']).with_score.order_by_score.paginate(:per_page => 3, :page => params[:page])
		
		@source = @token.path.first	
		# @pros = @namespace.pros.paginate(:page => 1, :per_page => 10)	
		# @cons = @namespace.cons.paginate(:page => 1, :per_page => 10)
		@comments = @namespace.comments
		
		@facts = Polyco.search("Fact #{@source.unique_name}").paginate(:page => 1, :per_page => 10)

		respond_to do |f|
			f.html {
			}
			
			f.js { 
				
			}	
		end

	end
	
	def edit
		@scope = params[:scope][:type].classify.constantize.find(params[:scope][:id])
		
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def update
			@nuniverse.description = params[:nuniverse][:description]
			@tags = []
			params[:nuniverse][:tags].split(',').each do |t|
				@tags << Tag.find_or_create(:name => t.strip)
			end
			@nuniverse.tags = @tags
			@nuniverse.images << Image.new(params[:image]) rescue nil
			
			@nuniverse.bookmarks << Bookmark.new(:url => params[:bookmark][:url], :name => params[:bookmark][:url])
			
			@nuniverse.active = 1 if !@tags.empty?
			@nuniverse.save
			redirect_to @nuniverse

	end
	
	def destroy
		@nuniverse.destroy

    respond_to do |format|
      format.html { redirect_to user_url(current_user) }
      format.xml  { head :ok }
    end
		
	end
	
	def suggest
		@path = params[:value].split('/')
		@subject = @path.to_a.pop
		@tags = @path.join(' ')
		@suggestions = Nuniverse.search(@subject, :conditions => {:tags => @tags}, :page => 1, :per_page => 10)
		
		respond_to do |format|
			format.html {}
			format.js {
				
			}
		end
	end
	
	def save
		@namespace = Nuniverse.find_by_unique_name(params[:namespace])
		if connection = current_user.connected_to?(@namespace)
			connection.destroy
			@action = 'remove'
		else
			current_user.nuniverses << @namespace
			@action = 'add'
		end
		
		respond_to do |f|
			f.html {}
			f.js {}
			f.json { 
				render :json  => {'action' => @action, 'element' => @namespace.to_json}
			}
		end
	end

	protected
	
end

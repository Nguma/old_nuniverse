class NuniversesController < ApplicationController
	
	require 'rwikibot'
	before_filter :find_user, :only => [:suggest, :show, :command, :index]
	before_filter :make_token, :except => [:index, :suggest, :discuss]
	# before_filter :find_source, :only => [:index]
	before_filter :update_session, :only => [:show]
 	after_filter :store_location, :store_source, :only => [:show]

	def index
		
		# @nuniverses = Nuniverse.find(:all, :conditions => ['name rlike ? OR unique_name rlike ?', params[:input], params[:input].gsub(' ','_')]).paginate(:page => params[:page], :per_page => 20)
		@nuniverses = Nuniverse.search(params[:input], :match_mode => :all).paginate(:page => params[:page], :per_page => 20)
		json = []
		@nuniverses.each do |n|
			json << n.to_json
			json.last['url'] = "/wdyto/#{n.unique_name}"
		end
		
		
		@new_nuniverse = Nuniverse.new(:name => params[:input], :unique_name => Token.generate(params[:input]))
		
		respond_to do |f|
			f.html {}
			f.js {}
			f.json { render :json => {:results => json}}
		end
	end
	
	
	def wdyto
		@namespace = Nuniverse.find_by_unique_name(params[:namespace])
		@source = @namespace
		@title = "#{@namespace.unique_name} on Wdyto"
		@comments = @namespace.comments
		@current_user_vote = @source.votes.by(current_user).first
		@votes = @source.votes.paginate(:page => params[:page], :per_page => 20)
		@connections = @source.connections.of_klass('Nuniverse').paginate(:page => 1, :per_page => params[:page])
		@connecteds = @source.connected_nuniverses.paginate(:page => 1, :per_page => params[:page])
		@comments = Comment.find(:all, :conditions => ['user_id = 0']).paginate(:page => 1)
		
		@procons = @source.connections.of_klass(['Tag', 'Nuniverse']).with_score.paginate(:per_page => 50, :page => 1)
		begin
			@client = TwitterSearch::Client.new 'wdyto'
			@tweets = @client.query :q => "##{@source.unique_name} OR @#{@source.unique_name} OR \"#{@source.name}\"", :lang => 'en' rescue nil
		rescue 
		end
			@tweets ||= []
		
		@links = []
		if @source.wikipedia_id && @source.description.blank?
		 	# @wiki = RWikiBot.new('u','p','http://en.wikipedia.org/w/api.php')
			
			# wikipedia_id = @source.name.titleize.gsub(/\s/,'_').gsub(':','')
			# @wikicontent = Wikipedia.find(@source.wikipedia_id)
			# 		if @wikicontent.redirect?
			# 			@wikicontent = Wikipedia.find(@wikicontent.content.scan(/\[\[([\w\s\:]+)\]\]/).to_s)
			# 		end
			# 		raise @wikicontent.content.split(/\n/).pretty_inspect
			begin
				doc = Hpricot open "http://en.wikipedia.org/wiki/#{@source.wikipedia_id}?action=render"
				@wikicontent = doc.search(" > p")[0..1]
				@source.description = @wikicontent.to_s
				@source.save
			rescue
				@wikicontent = []
			end
			
			
		else
			
		end
		# 
		# 	@source.wikipedia_id = wikipedia_id if @source.wikipedia_id.nil?
		# 	
		# 		@source.save
		# 		@links =  []
		# 	@wikicontent.content.scan(/\[\[([\w\s]+)\]\]/).flatten.uniq!.each do |c|
		# 				link = Nuniverse.find_or_create(:name => c)
		# 				link.wikipedia_id = c.titleize.gsub(' ','_')
		# 				link.save
		# 				@links << link
		# 				
		# 			end
		
		
		# @prosandcons = @source.connections.of_klass('Tag').paginate(:page => 1, :per_page => params[:page])
		
		@tags = []
		 @tags << "#{@source.name} "
			# @tags <<  @source.tags.sort {|a,b| b.weight <=> a.weight }.collect {|t| "#{t.name} #{t.parent.name rescue nil}"}# .each do |t|
			
					@source.tags.sort {|a,b| b.weight <=> a.weight }.each do |t|
								(t.weight/2).floor.times do |i|
									@tags << "#{t.name}"
								end
							end
		

		# @similars = Nuniverse.search(@tagstr[0..2].to_s, :field_weights => {:tags => 20, :name => 1}, :per_page => 10, :page => 1, :without => {:self_id => [@source.id]}, :match_mode => :any, :sort_mode => :relevance) rescue []


		@similars = Nuniverse.search(@tags.join(' '), :field_weights => {:primary_tags => 50, :secondary_tags => 30, :tertiary_tags => 15,  :name => 1}, :per_page => 10, :page => 1, :without => {:self_id => [@source.id]}, :match_mode => :any, :sort_mode => :relevance, :rank_mode => :wordcount) rescue nil
		# .with_rankings.paginate(:page => params[:page] , :per_page => 3)
	
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
	
	def twitter
		@tweets = Twitter::Search.new('').fecth()
		# oauth = Twitter::OAuth.new('mDpj6JFZdEi1jead8mmC3g', 'RLpbiKGRbFLEVCCGmekFujCrEKPyRjN2x6kF4hPZnA')
		# oauth.authorize_from_access('access token', 'access secret')
		
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

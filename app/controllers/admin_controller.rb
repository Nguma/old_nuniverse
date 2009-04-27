class AdminController < ApplicationController
	skip_before_filter :invitation_required
	before_filter :admin_required
	
	before_filter :find_source, :only => :save_layout
	
	def twitter
		@client = TwitterSearch::Client.new 'wdyto'
		@tweets = @client.query '#nyc'
		raise @tweets.inspect
		
		
		# TwitterOauth::Client.new(:consumer_key 'mDpj6JFZdEi1jead8mmC3g', :consumer_secret => 'RLpbiKGRbFLEVCCGmekFujCrEKPyRjN2x6kF4hPZnA')
			# Twitter::Client.new(:login => "nuniverse", :password => "abc123").timeline_for(:me, :since => 5.month.ago).each do |status|
			# 			@user = User.find_by_login(status.user.screen_name)
			# 			scan = status.text.scan(/^\#(\w+)\s*\+(\d)/i)[0]
			# 		
			# 			@nuniverse = Nuniverse.find_by_unique_name(scan[0].to_s)
			# 			@vote = scan[1]
			# 			raise "#{@user.firstname} voted +#{@vote} for #{@nuniverse.name}"
			# 		end
	end
	
	def oauth
		
	    oauth = Twitter::OAuth.new('mDpj6JFZdEi1jead8mmC3g', 'RLpbiKGRbFLEVCCGmekFujCrEKPyRjN2x6kF4hPZnA')
	    session['rtoken'] = oauth.request_token.token
	    session['rsecret'] = oauth.request_token.secret
	    redirect_to oauth.request_token.authorize_url
			return
 	end

	def oauthacc
		oauth = Twitter::OAuth.new('mDpj6JFZdEi1jead8mmC3g', 'RLpbiKGRbFLEVCCGmekFujCrEKPyRjN2x6kF4hPZnA')
		raise oauth.get
	end

	
	
	def index
	end
	
	def users
		@users = User.find(:all).paginate(:page => params[:page] || 1, :per_page => 20)
	end
	
	def groups
		@groups = Group.find(:all)
	end
	
	def send_activation_code
		@user = User.find(params[:id])
		UserMailer.deliver_activation_code(@user)
		redirect_to "/admin/users"
	end

	
	def scrap_dbpedia 
		@museum = Nuniverse.find_by_unique_name("museum")
		@manhattan = Nuniverse.find_by_unique_name("manhattan")
		
		@rsts.each do |rst|
			name = rst[0].gsub('_',' ')
			n = Nuniverse.create(:unique_name => "#{rst[0].gsub('_','-')}", :name => name) 
			n.images << Image.create(:source_url => rst[2]) rescue nil
			n.locations << Location.create(:name => name, :latlng => rst[1])
			@museum.nuniverses << n
			n.nuniverses << @manhattan
			@manhattan.nuniverses << n
		end
		
	end
	
	def scrap_ikea
		@ikea = Nuniverse.find(6262)
		@url = "http://www.ikea.com/us/en/catalog/productsaz/"
		
		23.times do |time|
			t = time+2
		doc = Hpricot open "#{@url}#{t}"
	
		
		(doc/:span/:a).each do |lnk|
			
			ikea = lnk.attributes['href'].scan(/(\/products\/(\w+))/)[0]
			unless ikea.nil? || ikea[1].nil?
				n = Nuniverse.find_by_unique_name("ikea-#{ikea[1]}")
				if n.nil?

					lnkdoc = Hpricot open "http://www.ikea.com#{lnk.attributes['href']}"
					
					
					n = Nuniverse.create(:active =>1 ,:unique_name => "ikea-#{ikea[1]}", :name => lnkdoc.at("#productName").inner_html.titleize, :description => lnkdoc.at("#productType").inner_html )
					n.bookmarks << Bookmark.create(:name => "#{n.name} at Ikea", :url => ikea[0])
					n.images << Image.create(:source_url => "http://www.ikea.com/#{lnkdoc.at("#productImg").attributes['src']}")
					n.tags << Tag.find_or_create(:name => n.description)
					
				end
				@ikea.nuniverses << n if n
				
			end
		end
	end
		
	end
	
	
	def netflix
		
		@api_key = "srnpu8b448ca2fj5q6vkrppd"
		@shared_secret = "nuMWRS9hRQ"
		require "netflix"
		@c = Netflix::AssHat.new(@api_key, @shared_secret, "nuniverse")
		raise @c.acquire_request_token("http://www.nuniverse.net").inspect
		
		# t = Finder::Netflix.new
		# 	
		# 	if session[:request_token].nil?
		# 		@request_token = t.request_token
		# 		session[:request_token] =  @request_token.token
		# 		session[:request_token_secret] =  @request_token.secret
		# 		redirect_to t.authorization_url
		# 	else
		# 		@request_token = OAuth::RequestToken.new(t.consumer,session[:request_token],session[:request_token_secret])
		# 		
		# 		@access_token = @request_token.get_access_token 
		# 		session[:request_token] = nil
		# 		session[:request_token_secret]
		# 	end
		# 	
	end
	
	def batch
		tag1 = Tag.find_or_create(:name => "video game")
		d_tag = Tag.find_or_create(:name => "video game developer")
		p_tag = Tag.find_or_create(:name => "video game publisher")
		tag4 = Tag.find_or_create(:name => "american")
	
		
		@ar = []
		@ambig = []
		@ar.each do |ar| 
			@n = Nuniverse.find_by_wikipedia_id(ar[0])
					
				doc = Hpricot open "http://en.wikipedia.org/wiki/#{ar[0]}?action=render"
				noarticle = (doc/"div.noarticletext").first
				if noarticle.nil?
						title = (doc/"table.infobox"/"th.summary"/"i").first.inner_html rescue CGI::unescape(ar[0].gsub('_',' '))
						unless title.nil?
						image = (doc/"table.infobox"/"img").first.attributes['src'] rescue nil
						desc =  doc.search(" > p")[0..1].to_s rescue nil
						genres = []
						developers = []
						publishers =[]
						@platforms = []
						 (doc/"table.infobox"/"tr").each do |tr|
							
							unless (tr/:a).empty?
								case (tr/:a)[0].attributes['href']
								when "http://en.wikipedia.org/wiki/Video_game_genres"	
									(tr/'td:nth(1)'/:a).each do |genre|
										genres << Tag.find_or_create(:name => genre.inner_html)
									end
								when "http://en.wikipedia.org/wiki/Video_game_developer"
									(tr/'td:nth(1)'/:a).each do |dev|
										wid = dev.attributes['href'].gsub('http://en.wikipedia.org/wiki/','')
									
										d = Nuniverse.find_by_wikipedia_id(wid)
										
										d = Nuniverse.find_or_create(:name => dev.inner_html, :uniqe_name => wid, :wikipedia_id => wid) if d.nil?
									
										d.tags << d_tag rescue nil
										developers << d
									end
								when "http://en.wikipedia.org/wiki/Video_game_publisher"
									(tr/'td:nth(1)'/:a).each do |dev|
											wid = dev.attributes['href'].gsub('http://en.wikipedia.org/wiki/','')

											p = Nuniverse.find_by_wikipedia_id(wid)
											p = Nuniverse.find_or_create(:name => dev.inner_html, :unique_name => wid, :wikipedia_id => wid) if p.nil?
											p.tags << p_tag rescue nil
											publishers << p
									end
								when "http://en.wikipedia.org/wiki/Computing_platform"
									(tr/'td:nth(1)'/:a).each do |dev|
											pl_tag = Tag.find_or_create(:name => dev.inner_html)
											pl_tag = pl_tag.redirect if pl_tag.redirect
											pl_tag.parent_id = '5757'
											pl_tag.save
											@platforms << pl_tag rescue nil
			
									end
								end
							end	
								
							
						end
								
						begin 
						if @n.nil?
							@n = Nuniverse.create(:name => title, :unique_name => Token.sanatize(title), :wikipedia_id => ar[0], :description => desc) 
							@n.tags << [tag1]
							@n.tags << @platforms rescue nil
						end
						@n.tags << genres rescue nil
						@n.connections << developers rescue nil
						@n.connections << publishers rescue nil
						
						
						
						if  !image.blank?
							@image = Image.find_or_create(:source_url =>image)
							@n.images << @image rescue nil
						end
					rescue
						@ambig << ar
					end
					
				end
			end
		end
	end
	
	
	def batch_4 
		@tag1 = Tag.find_by_name('video game')
		@tag2 = Tag.find_by_name('continent')
		@tag3 = Tag.find_by_id(6000)
		@tag4 = Tag.find_by_name('video game developer')
		@ns = Nuniverse.search("publisher", :match_mode => :all, :with => {:tag_ids => [@tag1.id]})
		
	
		@ns.each do |ns|
			raise ns.tags.inspect
		
			# ns.tags.delete @tag4 rescue nil
			ns.save
		end
	

	end
		
		
	def batch_3
	
	  
	 
		@actresses = Nuniverse.find(:all, :conditions => "id > 101813")
		# @bot = RWikiBot.new('u','p','http://en.wikipedia.org/w/api.php')
		# @page = @bot.page("#{actress.wikipedia_id}")
		@actresses.each do |actress|
			
			doc = Hpricot open "http://en.wikipedia.org/wiki/#{actress.wikipedia_id}?action=render"
			image = (doc/:table/:img).first.attributes['src'] rescue nil
		
			# image = @page.content.scan(/image\s\=\s(.*)\.(jpg|png)/).flatten
			# 	
			# 		hash = Digest::MD5.hexdigest(image[0])
			# 		raise hash.inspect
			# 		path = "#{hash[0..0]}/#{hash[0..1]}/#{image[0].gsub(' ','_')}.#{image[1]}"
			# 	raise path.inspect
			if  !image.blank?
				
				
			
				@image = Image.find_or_create(:source_url =>image)
			
				actress.images << @image rescue nil
			else 
			
			end
			
		end
	end
	
	
	def cleanup
		Tagging.find(:all, :conditions => "tag_type = 'Tag'").each do |tagging|
				if tagging.tag.nil?
					tagging.destroy
				else
					tagging.tag_id = tagging.tag.redirect_id if tagging.tag.redirect_id 
					tagging.save rescue nil
				end

		end
		
	end

	

	protected
	
	
	def boxing
			if FileTest.exist?("#{LAYOUT_DIR}/#{@source.class.to_s}_#{@source.id}.xml")
				@layout =	XMLObject.new(File.open("#{LAYOUT_DIR}/#{@source.class.to_s}_#{@source.id}.xml")).boxes rescue []
			else
				@layout  = XMLObject.new(File.open("#{LAYOUT_DIR}/Template_#{@source.class.to_s}.xml")).boxes
			end
		end
	
end

class Token
	
	attr_reader :fullscan
	attr_accessor :namespace,  :path, :body, :value, :images, :bookmarks, :vote, :author
	def initialize(str, params = {})
		
		return nil if str.blank?
		@images = []
		@bookmarks = []
		@author = params[:current_user]
		@fullscan = extract_urls(str).scan(/^\/([\w\_]+)((\/[\w\s]+)*)?(?:\/|\:)(.*)?/)[0]

		@body = @fullscan.last

		
		if t = Token.is_a_review?(@fullscan[1])
			@path = Path.new("#{@fullscan[0]}/review")
			@vote = Ranking.find_or_create(:rankable_id => @path.first.id, :rankable_type => @path.first.class.to_s, :score => t[1].to_i, :user_id => @author.id) 
			@value = Comment.create(:body => @body.strip, :user_id => @author.id ) unless @body.blank?
		else
			@path = Path.new("#{@fullscan[0]}#{@fullscan[2]}")
			make
		end
		
		@namespace = @path.first
		@namespace = Nuniverse.find_by_unique_name(@fullscan[0].downcase) if @namespace.nil?
		@namespace = @namespace.redirect if @namespace.redirect
		@namespace.images << @images rescue nil
		@namespace.bookmarks << @bookmarks rescue nil
				
	end	
	
	def extract_urls(str)
		
		@urls = Token.find_urls(str)
		
		@urls.each do |url|
			uri = URI.parse(url[0].to_s)
			http_path =  uri.path.blank? ? "/" : uri.path
			req = Net::HTTP.start(uri.host,uri.port).head(http_path)
			
			if !req['content-type'].nil? && req['content-type'].match('image/')
				@images << Image.find_or_create(:source_url => url[0].to_s)
			else
				if uri.host == "www.amazon.com"
					
				end
				@bookmarks << Bookmark.find_or_create(:url => url[0].to_s)
			end
			str = str.gsub(url[0].to_s, '')
		end
		return str
	end	
	
	def extract_categories(str)
		@path = str.scan(/^((\/[\w\s]+)+)\//)[0][0].to_s	
	end
	
	def to_s
		"#{@namespace.name} #{category}"
	end
	
	def tags
		@path.to_a[1..-1]
	end
	
	def uri
		"/#{@namespace.unique_name.downcase}/#{category if category}"
	end

	def make
		return nil if @body.blank?
		if @body.strip.match(/^\:?\/[\w\_]+/)
			@value = Nuniverse.find_or_create(:name => @body.strip)
		end
		
		# Nuniverse.create(:name => )
	end
	
	def regxp
		/\/#{@namespace.unique_name.downcase}\/?#{category}?/
	end
	
	def category
		@tag.name rescue nil
	end
	
	def query(params = {})
		q = [@namespace.aliases.collect {|c| "/#{c.unique_name}"},"/#{@namespace.unique_name}"].flatten.join("|")
		q << " "
		# t  << "#{[@tag.aliases.collect {|c| "/#{c.unique_name}"},"/#{@tag.unique_name}"].flatten.join("|")}" if @tag

	
		Fact.search(q, :conditions => {:parent_id => @namespace.id}, :order => :created_at, :sort_mode => :desc, :match_mode => :extended, :page => params[:page], :per_page => 30)
	
	end
	
	def sub_categories
		@namespace.facts.tagged(@tag).gather_tags
	end
	
	def result
		
		if @property.name == "name"
			return @source.name
		else
			
			return @source.property(@property).subject.body rescue ""
		end
	end
	
	protected
	
	def self.is_a_review?(str)
		return str.match(/^\/?rate it ([0-9]{1,2}) /i)
	end
	
	def self.parse(str)
		
		# category = Nuniverse.find_or_create(:name => fact.category, :is_unique => 0)  if fact.category
		urls = 
		
		urls.each do |url|
		
			path = (url[5].blank? ? "/" : url[5])
			req = Net::HTTP.start(url[2],80).head(path)
			if !req['content-type'].nil? && req['content-type'].match('image/')
				image = Image.create!(:source_url => url[0])
				return image
			else
				
				if url[0].match('youtube.com/watch')
					return 'Video'
				else

					if url[0].match(/www\.bestbuy\.com\/site\/olspage\.jsp\?skuId\=/i)
						doc = Hpricot open url[0]
						
						if doc
							content = (doc/"#pdpcenterwell")
							
							brand = (content/"#productsummary"/:h1).to_s.scan(/^[a-zA-Z0-9\s]+/)
							Nuniverse.find_or_create(:unique_name => "brand_#{brand}", :name => brand)
							modelname = (content/"#detailband")
							raise modelname.inspect
							# Nuniverse.find_or_create(:unique_name => )
							raise (content/"#imagepreview"/:img).first.attributes['src'].inspect
					end
				end
				end
			end
			
		end
		
		
	end
	
	def self.find_urls(str)
		return str.scan(/\b((https?|ftp):\/\/([a-z0-9\.\-\_]+)(\/[-A-Z0-9+\&\@\#\/%=~_|!:,\.;]*)?(\?[-A-Z0-9+\&\@\#\/%=~_|!:,\.;]*)?)/ix)
		# return str.scan(/((https?:\/\/)?(([a-z0-9\-\_]+\.{1})?([a-z0-9\-\_]+\.[a-z]{2,5}))((\s|\/|\?)\S*))/ix)
	end
	
	def self.traverse(token)
		url = "http://en.wikipedia.org/wiki/#{token}?action=edit"
		father = Nuniverse.find_or_create(token)
		
		doc = Hpricot open url
		if doc
			content = (doc/:textarea).first.inner_text rescue nil
			if content
				p = content.scan(/\n\'\'\'(.*)\n/)[0] rescue []
				p = p[0].split(". ").first.gsub(/\<ref .*\<\/ref\>/, '').gsub(/\'\'\'/,'') rescue ""
				sentence = p.gsub(/\{\{.*\}\}/,'')
				f = Fact.create(:body => sentence.strip)
				f.objects << father rescue nil
				Nuniversal.tokenize(sentence).each do |token|
					unless Nuniverse.find_by_unique_name(Nuniversal.sanatize(token))
						n = Nuniverse.find_or_create(token)
						f.subjects << n rescue nil
						father.nuniverses << n rescue nil
						Nuniversal.traverse(Nuniversal.sanatize(token)) 
					end
				end
			end
		end
		
	end
	
	def self.humanize(str)
		str = str.gsub('_',' ')
	end
	
	def self.sanatize(str)
		str.to_s.titleize.gsub(' ','_').gsub(/\W/,'')
	end
	
	def self.find(str)
		tks = str.scan(/(\s|^)(\/[\w\_\/]+)/i) || []
		tks.collect {|t| Token.new("#{t[1]}/")}
	end
	
	def self.tokenize(str)
		str.scan(/(^|\s)\/([\w\_\/]+)/i) || []

	end
	
	
	def self.extract_urls(str)
		
		@urls = Token.find_urls(str)
		
		@urls.each do |url|
			uri = URI.parse(url[0].to_s)
			http_path =  uri.path.blank? ? "/" : uri.path
			req = Net::HTTP.start(uri.host,uri.port).head(http_path)
			
			if !req['content-type'].nil? && req['content-type'].match('image/')
				@images << Image.find_or_create(:source_url => url[0].to_s)
			else
				if uri.host == "www.amazon.com"
					
				end
				@bookmarks << Bookmark.find_or_create(:url => url[0].to_s)
			end
			str = str.gsub(url[0].to_s, '')
		end
		return {
			'images' => @images,
			'bookmarks' => @bookmarks
		}
	end
end
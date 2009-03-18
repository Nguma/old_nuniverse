module Nuniversal
	protected
	
	CONFIG_FILE = File.read(RAILS_ROOT + "/config/gmaps_api_key.yml")
	GOOG_GEO_KEY = YAML.load(CONFIG_FILE)[RAILS_ENV]
		
	def humanize(token)
		token.gsub('_',' ')
	end

	

	
	# def tokenize_new(str, source)
	# 		ptokens = str.scan(/\<([\w\s\-\_\?\!\@]+)\>/i) || []
	# 		
	# 		tokens = []
	# 		ptokens.each do |t|
	# 			# sub = t.scan(/(.+)\@(.+)/)[0]
	# 			tokens << Token.new(:property => t[0], :source => source)
	# 		end
	# 		tokens
	# 	end
	
	def contains_url?(str)
		scan = str.scan(/((https?:\/\/)?[a-z0-9\-\_]+\.{1}([a-z0-9\-\_]+\.[a-z]{2,5})\S*)/ix)[0]
		return true if !scan.nil?
		return false
	end
	
	def scan_url(str)
		return str.scan(/((https?:\/\/)?[a-z0-9\-\_]+\.{1}([a-z0-9\-\_]+\.[a-z]{2,5})\S*)/ix)[0]
	end
	
	def parse_amazon
		
		asin = url.scan(/(http:\/\/www\.amazon\.com\/.+\/(B0\w+)\/.+)(\s|$)/)[0]
	  awsobject = Finder::Search.find(:item_id => asin[1], :service => 'amazon', :operation => "ItemLookup")[0]
	  @comment.body = @comment.body.gsub(/(http:\/\/www\.amazon\.com\/.+\/(B0\w+)\/.+)(\s|$)/,"##{asin[1]}")
	end
	
	def parse_url(url)
		@t = Bookmark.find_by_url(url)
		return @t unless @t.nil?
		doc = Hpricot open(url)
		@t = Bookmark.new(:url => url)
		if url.match('en.wikipedia.org/wiki/')
			
			@article = self.get_content_from_wikipedia(doc)
			@t.description = self.wikipedia_description(@article)
			@t.label = "#{(doc/:h1).first.inner_html.to_s} on Wikipedia"
			@t.url = url		
		else
			@t.name = (doc/:title).first.inner_html.to_s.blank? ? params[:url] : (doc/:title).first.inner_html.to_s
			@t.description = (doc/:p).first.inner_html.to_s rescue ""
			@t.url = url
		end
		@t

	end
	
	def get_content_from_wikipedia(doc)
			items_to_remove = [
			  "#contentSub",        #redirection notice
			  "div.messagebox",     #cleanup data
			  "#siteNotice",        #site notice
			  "#siteSub",           #"From Wikipedia..." 
			  # "table.infobox",      #sidebar box
			  "#jump-to-nav",       #jump-to-nav
			  "div.editsection",    #edit blocks
			  "table.toc",          #table of contents 
			  "#catlinks",           #category links
				"#cite_note-0"
			  ]

			

			@article = (doc/"#content").each do |content|
			  #change /wiki/ links to point to full wikipedia path

			  (content/:a).each do |link|
			    unless link.attributes['href'].nil?
			      if (link.attributes['href'][0..5] == "/wiki/")
			        link.attributes['href'].sub!('/wiki/', 'http://en.wikipedia.org/wiki/')
			      end
			    end
			  end  

			  #remove unnecessary content and edit links
			  items_to_remove.each { |x| (content/x).remove }

			  #replace links to create new entries with plain text
			  (content/"a.new").each do |link|
			    link.parent.insert_before Hpricot.make(link.attributes['title']), link
			  end.remove
			end 
		
			return @article
			return "#{(@article/:p)[0..1]}"
	end
	
	def wikipedia_description(wiki_content)
		dc = (wiki_content/:p).first
		(dc/:sup).remove
		(dc/:span).remove
		(dc/:br).remove
		(dc/:p).each do |a|
			a.swap(a.inner_html)
		end
		(dc/:a).each do |a|
			a.swap(a.inner_html)
		end
		(dc/:b).each do |a|
			a.swap(a.inner_html)
		end
		(dc/:i).each do |a|
			a.swap(a.inner_html)
		end
		dc.to_s
	end
		
	def save_page(page_id)
		@doc = Parser.new("#{LAYOUT_DIR}/#{page_id}.xml")
		if @doc.write( params[:xml].to_s)
			respond_to do |f|
				f.xml {head :ok}
			end
		else
			respond_to do |f|
				f.xml {raise params[:xml].inspect}
			end
		end
	end
		
end
module Nuniversal
	# GOOG_GEO_KEY = "ABQIAAAAzMUFFnT9uH0xq39J0Y4kbhTJQa0g3IQ9GZqIMmInSLzwtGDKaBR6j135zrztfTGVOm2QlWnkaidDIQ"
	#GOOG_GEO_KEY = "ABQIAAAA8l8NOquAug7TyWVBqeUUKBQEtxNUKhNqH9fVyPPamALnlXdwmxQXyPYD9XOjHMOgc3AuNtDGwMBNHQ"
	
	CONFIG_FILE = File.read(RAILS_ROOT + "/config/gmaps_api_key.yml")
	GOOG_GEO_KEY = YAML.load(CONFIG_FILE)[RAILS_ENV]
	
	
	def self.localize(address, source)
		begin
			@geoloc = Graticule.service(:google).new(GOOG_GEO_KEY).locate(address.to_s)
		
			return Location.new(
			:name => source.name,
			:full_address => "#{@geoloc.street} #{@geoloc.locality} #{@geoloc.region} #{@geoloc.zip} #{@geoloc.country}",
			:latlng => @geoloc.coordinates.join(',')
			)
		rescue
			raise "Error parsing a location from this address: #{address} to source: #{source}"
		end
	end
	
	class LabelValue
		attr_reader :label, :value
		def initialize(label, value = nil)
			@label = label
			@value = value.nil? ? label : value
		end
	end
		
	
	def self.tokenize(str)
		str.scan(/\#([\w\-]+)/i)[0] || []
	
	end
	
	def self.parse_url(url)
		doc = Hpricot open(url.gsub(/\s|,/,'_'))
		@t = Tag.new(:kind => "bookmark")
		if url.match('en.wikipedia.org/wiki/')
			
			@article = self.get_content_from_wikipedia(doc)
			@t.description = self.wikipedia_description(@article)
			@t.label = "#{(doc/:h1).first.inner_html.to_s} on Wikipedia"
			@t.url = url		
		else
			@t.label = (doc/:title).first.inner_html.to_s.blank? ? params[:url] : (doc/:title).first.inner_html.to_s
			@t.description = (doc/:p).first.inner_html.to_s rescue ""
			@t.url = url
		end
		@t

	end
	
	def self.get_content_from_wikipedia(doc)
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
	
	def self.wikipedia_description(wiki_content)
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
		
	def self.collect_infos(params)
		tag = params[:tag]
		case params[:kind].singularize
		
		when "bookmark"
			return tag.url.scan(/http.{1,3}\/\/([^\/]*).*/)[0] 

		when "comment"
			return "#{connection.owner.login.capitalize} - #{connection.created_at.strftime('%h %d, %H:%M')}"

		else
			infos = nil
		end
			
		 Tagging.select(
			:perspective => params[:perspective],
			:label => infos ? infos.join('|') : nil,
			:subject => params[:tag],
			:order => params[:order] || nil,
			:page => params[:page] || 1,
			:per_page => 3)
	
	end
	
	class Connection
		
		def self.find(params)
				
				Tagging.select(
					:perspective => params[:perspective],
					:tags => params[:tags] || [params[:kind]],
					:subject => params[:subject] || nil,
					:order => params[:order] || params[:order],
					:page => params[:page] || 1, 
					:per_page => params[:per_page],
					:label => params[:label] || nil
				)
		end
	end
	
end
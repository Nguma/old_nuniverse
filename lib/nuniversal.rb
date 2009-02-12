module Nuniversal

	
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
	
	class Token
		attr_reader :property, :source, :formula
		def initialize(params)
			@property = Tag.find_by_name(params[:property])
			# @group = Group.find_by_unique_name(params[:group])
			@source = params[:source]
			@formula = params[:formula] || build_formula
		end		
		
		def build_formula
			"<#{@property.name}>"
		end
		
		def result
			
			if @property.name == "name"
				return @source.name
			else
				
				return @source.property(@property).subject.body rescue ""
			end
		end
	end
		
	def self.humanize(token)
		token.gsub('_',' ')
	end
	def self.sanatize(token)
		token.titleize.gsub(' ','_').gsub(/\|.*/,'')
	end
	
	def self.tokenize(str)
		str.scan(/\[\[([\w\s\-\_\,\?\!]+)\]\]/i) || []
	end
	
	def self.tokenize_new(str, source)
		ptokens = str.scan(/\<([\w\s\-\_\?\!\@]+)\>/i) || []
		
		tokens = []
		ptokens.each do |t|
			# sub = t.scan(/(.+)\@(.+)/)[0]
			tokens << Token.new(:property => t[0], :source => source)
		end
		tokens
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
		
	
	
	class Parser
		
		attr_accessor :file, :doc
		
		def initialize(file)
			@file = file
		end
		
		def read
			
			@doc = Hpricot::XML(File.read(@file))
			@doc
		end
		
		def write(xml)
			
		
			File.open(@file, 'w') do |f|
				f.puts(xml)
			end
		end
	end
	
end
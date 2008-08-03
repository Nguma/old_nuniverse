class Section
	attr_reader :path, :perspective, :no_wrap, :kind
	
	def initialize(params = {})
		@path = TaggingPath.new params[:path]
		@order = params[:order] || nil
		@perspective = params[:perspective] || nil
		@kind = map_kind(params[:kind])
		@degree = params[:degree] || "all"
		@page = params[:page] || 1
		@no_wrap = params[:no_wrap] || nil
		@user = params[:user] || nil
	end

	def subject
		@path.last_tag
	end
	
	def connections(params = {})
		kind = params[:kind]|| @kind
		kind = "|location|city|country|restaurant|continent|museum|bar" if kind == "location"
		kind = nil if kind.blank?
		order = params[:order] || @order
		params[:degree] =  nil
		if @perspective == "you"
			path = @path
			user = params[:user]
		else
			user = nil
			path = public_path
		end
		Tagging.with_kind_like(kind).with_user(user).with_path(path,params[:degree]).include_object.groupped.with_order(order).paginate(
				:page => @page, 
				:per_page => 20
		)
	end
	
	def map_kind(kind = nil)
		kind =  tabs.select {|t| kind.downcase == t.value}.first.value rescue nil
		if kind.nil? || kind.blank?
			kind = tabs[0].value
		end
		kind
		
	end
	
	def empty?
		overview.empty?
	end
	
	def overview(params = {})
		Tagging.with_path(@path, "all").with_user(@user).include_object.by_latest.paginate(
		:page => params[:page] || 1,
		:per_page => 20)
	end
	
	def public_path
		TaggingPath.new [@path.last_tag]
	end
	
	def is_web_service?
		return false if @perspective.nil?
		return false if ['you','everyone','private','public'].include?(@perspective)
		return true
	end
	
	def service
		perspective
	end
	
	def results(params = {})
		params[:kind] ||= kind
		params[:service] ||= perspective
		case params[:service]
		when "google"
			return Googleizer::Request.new("#{subject.label} -amazon.com -ebay.com -youtube.com", :mode => params[:kind]).response.results
		when "amazon"
			return Awsomo::Request.new(
				:query => subject.label, 
				:category => params[:kind]
				).response.items
		when "ebay"
			return []
		when "freebase"
			match   = nil
			results = []
			unless subject.property("freebase_id").blank?
				match = Metaweb::Type::Object.find(subject.property("freebase_id"))
		  end
			if match.nil?
				results =  Freebaser::Request.new(
				  :query  => subject.label,
				  :path   => path,
				  :type   => subject.kind
				).results 
				if results.length == 1
	  		  match = Metaweb::Type::Object.find results.first.id
	  		  tag.data += " #freebase_id #{match.id}"
	  		  tag.description = match.article if tag.description.blank?
	  		  tag.save
	  	  end
			end
			results
		when "daylife"
			
			return Daylife::Request.new(
				:query => subject.label,
				:mode => params[:kind],
				:@per_pages => 10
			).results
		when "ebay"
			return EbayShopping::Request.new(:find_items, :query_keywords => subject, :max_entries => 10).response.items
		else
			return connections(params)
		end
	end
	

	
	def tabs(service = perspective)
		filt = Filter.new(service, @path)
		case service
		when 'google'
			[
				filt.add('Web'),
				filt.add('Images'),
				filt.add('News'),
				filt.add('Places', 'local'),
				filt.add('Videos', 'video')
			]
		when 'ebay'
			[filt.add('All')]
		when 'freebase'
			[filt.add('About')]
		when 'flickr'
			[filt.add('Images')]
		when 'twitter'
			[filt.add('Tweets')]
		when 'daylife'
			[
				filt.add('News'),
				filt.add('Quotes'),
				filt.add('Images'),
				filt.add('Topics')
			]
		when 'amazon'
			[
				filt.add('All'),
				filt.add('Apparel'),	
				filt.add('Books'),
				filt.add('Electronics'),
				filt.add('Music'),
				filt.add('Movies', 'Video')
			]
		else
			[
				filt.add('Overview', "overview"),
				filt.add('Bookmarks', "bookmark"),
				filt.add('Comments', "comment|pro|con"),
				filt.add('Events',"event"),
				filt.add('Images', "image"),
				filt.add('News', "news"),
				filt.add('People',"person"),
				filt.add('Places', "location"),
				filt.add('Products', "item"),
				filt.add('Topics',"topic"),
				filt.add('Videos',"video")
			]
		end
	end
end
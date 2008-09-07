class Tag < ActiveRecord::Base
  has_many :images,  	:conditions => ["images.parent_id is null"]
	
	
	validates_presence_of :label
	
	alias_attribute :name, :label
	attr_accessor :address
	
	after_create  :find_coordinates
		
	def after_initialize
		@address = Nuniverse::Address.new(self)
	end
		
	def self.connect(params)
		gum =  params[:gum].collect { |k,v| "##{k} #{v}" }.join("") rescue ""
		@object = Tag.find_by_label_and_kind_and_url(
		  params[:label], params[:kind], params[:url]
		)
		if @object.nil?
			@object = Tag.create(
				:label        => params[:label], 
				:kind         => params[:kind],
				:description  => params[:description] || "",
				:url          => params[:url],
				:service      => params[:service],
				:data         => gum
			)
		else
			@object.description = params[:description] || @object.description
			@object.url = params[:url] || @object.url
			@object.update_data(params[:gum]) if params[:gum]
			@object.find_coordinates
			
			@object.save!
		end
		
		
		
		unless params[:user_id].nil?
			@subject = Tag.find(TaggingPath.new(params[:path]).last_tag.id)

			@tagging = Tagging.create(
				:subject 	=> @subject,
				:object 	=> @object,
				:path    	=> "_#{params[:path]}_",
				:user_id	=> params[:user_id],
				:restricted => params[:restricted],
				:description => params[:relationship]
			)
		end
		
		@tagging
	end
	
	def has_address?
		return true if self.kind == "address"
		return true if !address.full_address.blank?
		false
	end
	
	def has_coordinates?
		address.has_coordinates?
	end
	
	def coordinates
		address.coordinates
	end
	
	def precision
		return property('sub_type') unless property('sub_type').blank?
		kind
	end
	
	def flashvars
		data.scan(/#flashvars[\s]+([^#|\[|\]]+)*/).to_s rescue ""
	end
	
	def property(prop)
		data.scan(/##{prop}[\s]+([^#|\[|\]]+)*/).to_s.rstrip rescue ""
	end
	
	def ws_id
		data.scan(/#ws_id[\s]+([^#|\[|\]]+)*/).to_s rescue nil
	end
	
	def kinds
		kind.split("#")
	end
	
	def kind
		return nil if super.nil?
		super.split('#')[0]
	end
	
	
	def thumbnail
		return images.first.public_filename(:small) unless images.empty?
		return property('thumbnail') unless property('thumbnail').blank?
		# return "/images/icons/#{kind}.png" if FileTest.exists?("public/images/icons/#{kind}.png")
		return nil
	end
	
	def icon
		kinds.each do |kind|
			return "/images/icons/#{kind}.png" if FileTest.exists?("public/images/icons/#{kind}.png")
		end
		return nil
	end
	
	
	def avatar
		return images.first.public_filename unless images.empty?
		return property('image') 
	end
	
	def price
		data.scan(/#price[\s]+([^#|\[|\]]+)*/).to_s rescue ""
	end
	
	def info
		return property('address') if has_address?
		return "#{property('price')} "
	end
	
	def link
		return url unless url.nil? || url.blank?
		return property('url')
	end
	
	def details
		"#{description.capitalize} #{property('price')} #{property('address')} #{property('tel')}"
	end
	
	def replace(property,value)
		data = self.data || ""
		new_data = data.gsub(/##{property}[\s]+([^#|\[|\]]+)/,'')
		self.data = "#{new_data}##{property} #{value}"
	end
	
	def replace_property(property,value)
		data = self.data || ""
		new_data = data.gsub(/##{property}[\s]+([^#|\[|\]]+)/,'')
		self.data = "#{new_data}##{property} #{value}"
	end
	
	def update_data(gums)		
		gums.each do |prop|
			replace(prop[0],prop[1])
		end
	end
	
	def weather
		return nil unless has_coordinates?
		g = Geonamer::Request.new.weather(:lat => address.lat, :lng => address.lng)
		return "#{g.temperature}F / #{g.clouds} / #{g.conditions}" rescue "No information available"
	end
	
	def rss
		return if property('rss').blank?
		Rssr.news(property('rss'))
	end
	
	# def self.find_taggeds_with(params)
	# 		
	# 		@context = params[:context].collect {|s| s.id}.join('_')
	# 		# @subjects = params[:subjects].collect {|s| s.id}.join(',')
	# 		# @objects = params[:objects].collect {|o| o.id}.join(',') if params[:objects]
	# 		if params[:reverse]
	# 			oid = "subject_id"
	# 			sid = "object_id"
	# 			
	# 		else
	# 			oid = "object_id"
	# 			sid = "subject_id"
	# 		end
	# 		
	# 		sub_query = "SELECT #{oid} FROM taggings WHERE path rlike '_#{@context}_'"
	# 		sub_query << " AND #{sid} in (#{@subjects}) " if @subjects
	# 		sub_query << " AND #{oid} in (#{@objects}) " if @objects
	# 		sub_query << " AND user_id in (#{params[:user_id]})" if params[:user_id]
	# 		sub_query << " GROUP BY #{oid} HAVING count(#{oid}) >= 1 ORDER BY path ASC"
	# 		query = "SELECT tags.* FROM tags WHERE tags.id in (#{sub_query})"
	# 		query << " AND kind = '#{params[:kind]}'" if params[:kind]
	# 		query << " ORDER BY label DESC"
	# 		
	# 		Tag.find_by_sql(query)
	# 	end
	
	# named_scope :with_label_like, lambda { |label| 
	# 	return label.nil? ? {} : {:conditions => ["label like ?","%#{label}%"]}
	# }
	
  named_scope :with_kind_like, lambda { |kind|
   	return kind.nil? ? {} : {:conditions => ["kind like ?", "%#{kind}%"]}
  }
	
  named_scope :with_kind, lambda { |kind|
   	return kind.nil? ? {} : {:conditions => ["kind = ?", kind]}
  }
   
  named_scope :with_property, lambda { |prop_name, prop_value|
 		return kind.nil? ? {} : {:conditions => ["data rlike ?", "##{prop}[\s]+#{prop_value}/"]}
  }

	named_scope :with_label_like, lambda {|label|
		return label.nil? ? {} : {:conditions => ["label rlike ?","^.\{0,4\}#{label}.\{0,6\}$"]}
	}



	def find_coordinates
		Nuniverse::Address.find_coordinates(self)
	end
	
	def match_freebase_record(record)
		description = record.article if description.blank?
		self.replace('freebase_id', record.id)
		save
	end
	
	def essential_elements
		[]
	end

	def find_similars
		Tag.with_label_like(self.label).paginate(:page => 1, :per_page => 8)
	end
	

	def update_data(new_data)
		new_data.scan(/\s*#([\w_]+)[\s]+([^#|\[|\]]+)*/).each do |gum|
			replace(gum[0].to_s,gum[1].to_s)
		end
	end
	
	def self.find_or_create(params)
		tag = Tag.with_label_like(params[:label]).with_kind_like(params[:kind]).find(:first)
		if tag.nil?
			if params[:label].match(/^http:\/\/.+/)
				tag = Tag.create(
					:label => params[:label], 
					:kind => "bookmark",
					:url => params[:label]
				)
			else
				
			tag = Tag.create(
				:label => params[:label], 
				:kind => params[:kind]
			) 
			end
		
		end
		tag
	end
	
	def connections(params = {})
		context = TaggingPath.new(params[:context])
		Tagging.find(:all, :conditions => ['object_id = ?', self.id], :group => "subject_id")
	end
	
	def subject_of(params = {})
		Tagging.with_subject(self).with_order(params[:order] || "rank").paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 5)
	end
	
	def object_of(params = {})
		Tagging.with_object(self)
	end
	
	def properties
		data.scan(/#([\w]+)[\s]+([^#|\[|\]]+)*/).collect {|s| Nuniverse::LabelValue.new(s[0],s[1])}
	end
	
	def title
		self.kind == "person" ? label.titleize  : label.capitalize
	end
	
	def add_image(params)
		if params[:source_url]
	    image = Image.new(:source_url => params[:source_url])
	    image.tag_id = self.id
	    image.save!
	  end
	end
  
end

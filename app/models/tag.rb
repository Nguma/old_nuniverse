class Tag < ActiveRecord::Base
  has_one :avatar
	
	validates_presence_of :label, :kind
	
	alias_attribute :name, :label
	attr_accessor :address
	
	after_create  :find_coordinates
		
	def after_initialize
		@address = Nuniverse::Address.new(self)
	end
	
	def self.connect(params)
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
				:data         => params[:gum].collect { |k,v| "##{k} #{v}" }.join("")
			)
		else
			@object.description = params[:description] || @object.description
			@object.url = params[:url] || @object.url
			@object.update_data(params[:gum])
			@object.find_coordinates
			
			@object.save!
		end
		
		
		
		unless params[:user_id].nil?
			@subject = Tag.find(params[:path].split('_').last)

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
		return true if !address.full_address.blank?
		false
	end
	
	def has_coordinates?
		address.has_coordinates?
	end
	
	def coordinates
		address.coordinates
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
	
	def data_image
		data.scan(/#[image|thumbnail]+[\s]+([^#|\[|\]]+)*/).to_s rescue ""
	end
	
	def thumbnail
		return avatar.public_filename(:large) unless avatar.nil?
		return data_image unless data_image.blank?
		return "/images/icons/#{kind}.png" if FileTest.exists?("public/images/icons/#{kind}.png")
		return "/images/icons/icon_nuniverse.png"
	end
	
	def price
		data.scan(/#price[\s]+([^#|\[|\]]+)*/).to_s rescue ""
	end
	
	def info
		return property('address') if has_address?
		return "#{property('price')} "
	end
	
	def details
		"#{description.capitalize} #{property('price')} #{property('address')} #{property('tel')}"
	end
	
	def replace(property,value)
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
	
	named_scope :with_label_like, lambda { |label| 
		return label.nil? ? {} : {:conditions => ["label like ?","%#{label}%"]}
	}
	
  named_scope :with_kind_like, lambda { |kind|
   	return kind.nil? ? {} : {:conditions => ["kind like ?", "%#{kind}%"]}
  }
	
  named_scope :with_kind, lambda { |kind|
   		return kind.nil? ? {} : {:conditions => ["kind = ?", kind]}
  }
   
  named_scope :with_property, lambda { |prop_name, prop_value|
 		return kind.nil? ? {} : {:conditions => ["data rlike ?", "##{prop}[\s]+#{prop_value}/"]}
  }



	def find_coordinates
		Nuniverse::Address.find_coordinates(self)
	end
  
end

class Tag < ActiveRecord::Base
  has_one :image,  :foreign_key => :tag_id
	has_many :taggings_from, :dependent => :destroy, :foreign_key => :subject_id, :class_name => :taggings
	has_many :taggings_to, :dependent => :destroy, :foreign_key => :object_id, :class_name => :taggings
	has_many :subjects, :through => :taggings_to
	has_many :objects, :through => :taggings_from
	
	validates_presence_of :label
	
	alias_attribute :name, :label
	attr_accessor :address
	
	after_create  :find_coordinates
		
	def after_initialize
		@address = Nuniverse::Address.new(self)
	end
	
	def connect(params)
		@tagging = Tagging.select(
			:subject => self,
			:tags => [params[:kind], params[:label]]
		)
		if @object.nil?
			@object = Tag.find_or_create(:label => params[:label], :kind => params[:kind])
			@tagging = Tagging.create(
						:subject => self, 
						:object => @object,
						:kind => params[:kind],
						:public => params[:public] || 0
			)
		end
	end
		
	def object
		self
	end
	
	def tags
		Tagging.tags(self)
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
	
	def find_coordinates
		Nuniverse::Address.find_coordinates(self)
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
		
	
	def thumbnail
		image_tag = Tagging.find(:first, :conditions => ['subject_id = ? AND kind = "image"', self.id])
		if image_tag.nil? 
			return property('thumbnail') unless property('thumbnail').blank?
			return nil
		else
			return image_tag.object.image.public_filename(:small) rescue ""
		end
	end
	
	def icon
		kinds.each do |kind|
			return "/images/icons/#{kind}.png" if FileTest.exists?("public/images/icons/#{kind}.png")
		end
		return nil
	end
	
	
	def avatar
		image_tag = Tagging.find(:first, :conditions => ['subject_id = ? AND kind = "image"',self.id])
		return image_tag.object.image.public_filename unless image_tag.nil?
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
	
	def replace_property(property,value)
		data = self.data || ""
		new_data = data.gsub(/##{property}[\s]+([^#|\[|\]]+)/,'')
		self.data = "#{new_data}##{property} #{value}"
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
		
  named_scope :with_kind_like, lambda { |kind|
   	return kind.nil? ? {} : {:conditions => ["kind rlike ?", "(^|#)(#{kind.gsub('#','|')})(#|$)"]}
  }
	
  named_scope :with_kind, lambda { |kind|
   	return kind.nil? ? {} : {:conditions => ["kind = ?", kind]}
  }
   
  named_scope :with_property, lambda { |prop_name, prop_value|
 		return kind.nil? ? {} : {:conditions => ["data rlike ?", "##{prop}[\s]+#{prop_value}/"]}
  }

	named_scope :with_label_like, lambda {|label|
		return label.nil? ? {} : {:conditions => ["label rlike ?","#{label}"]}
	}
	
	named_scope :with_label, lambda { |label| 
		return label.nil? ? {} : {:conditions => ["label = ?","#{label}"]}
	}
	
	named_scope :with_tags, lambda { |kind| 
		return kind.nil? ? {} : {
			:joins => "LEFT OUTER JOIN tagggings.TA on TA.subject_id = tags.id",
			:conditions => ["TA.kind = #{kind} OR tags.kind = #{kind} "]}
	}
		
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
		
		
		tag = Tag.with_label(params[:label]).with_kind(params[:kind]).find(:first)
		if tag.nil? || params[:new]
			if params[:label].match(/^http:\/\/.+/)
				params[:kind] ||= 'bookmark'
				tag = Tag.create(params)
			else

			tag = Tag.create(params) 
			end
		
		end
		

		tag
	end
	
	
	def connections(params = {})
		params[:users] ||= 0
		
		Tagging.select(
			:perspective => params[:perspective] ,
			:subject => self,
			:tags => params[:tags] || nil
		)
	end
	
	def lists(params = {})
		List.created_by(params[:user] || nil).bound_to(self)
	end

	def properties
		data.scan(/#([\w]+)[\s]+([^#|\[|\]]+)*/).collect {|s| Nuniverse::LabelValue.new(s[0],s[1])}
	end
	
	def title
		self.kind == "person" ? label.titleize  : label.capitalize
	end
	
	def add_image(params)
		if !params[:uploaded_data].blank?

	    image = Image.new(:uploaded_data => params[:uploaded_data])
	  else
			image = Image.new(:source_url => params[:source_url])
		end
		image.tag_id = self.id
    image.save!
	end
	
	def tag_with(tags, params = {})
		tags.each do |t|
			Tagging.create!(:subject_id => params[:context] || 0, :object => self, :kind => t, :public => params[:public] || 1)
		end
	end
  
	def update_with(params)
		self.kind = params[:kind] if params[:kind]
		self.replace_property('address', params[:address].to_s) if params[:address]
		self.replace_property("tel", params[:tel]) if params[:tel]		
		self.replace_property("latlng", params[:latlng]) if params[:latlng]
		self.url = params[:url] if params[:url]
		self.description = params[:description] if params[:description]
		self.save
	end
	

end

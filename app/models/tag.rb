class Tag < ActiveRecord::Base
  has_one :image,  :foreign_key => :tag_id
	has_many :connections_from, :dependent => :destroy, :foreign_key => :subject_id, :class_name => 'Connection'
	has_many :connections_to, :dependent => :destroy, :foreign_key => :object_id, :class_name => 'Connection'
	has_many :subjects, :through => :connections_to
	has_many :objects, :through => :connections_from
	
	has_many :taggings, :as => :taggable
	belongs_to :taggable, :polymorphic => true
	
	validates_presence_of :label
	
	alias_attribute :name, :label
	attr_accessor :address
	
	after_create  :find_coordinates
	
	
	def after_initialize
		@address = Nuniversal::Address.new(self)
	end
	
	def connect_with(tag, params = {})
		params[:as] ||= []

		@c = Connection.find_or_create(
			:subject => self,
			:object => tag,
			:public => 1
		)
		
		params[:as].each do |k|
			
			Tagging.create(
				:taggable => @c,
				:predicate => k.strip
				)
			
		end

		if tag.kind != "Category"
			Connection.create (
				:subject => tag,
				:object => self,
				:public => 1
			)		rescue nil
		end

		@c
	end

	
	
	def tags(params = {})
		taggings.collect {|c| c.predicate}
	end
	
	def has_address?
		return true if self.kind == "Location"
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
		Nuniversal::Address.find_coordinates(self)
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
		
	def icon
		kinds.each do |kind|
			return "/images/icons/#{kind}.png" if FileTest.exists?("public/images/icons/#{kind}.png")
		end
		return nil
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
		return label.nil? ? {} : {:conditions => ["label like ?","#{label}%"]}
	}
	
	named_scope :with_label, lambda { |label| 
		return label.nil? ? {} : {:conditions => ["label = ?","#{label}"]}
	}
	
	named_scope :with_url, lambda { |url| 
		return url.nil? ?  {} : {:conditions => ["url = ?", "#{url}"]}
	}

	named_scope :with_tags, lambda { |kind| 
		return kind.nil? ? {} : {
			:joins => "LEFT OUTER JOIN connections on connections.subject_id = tags.id",
			:conditions => ["connections.predicate = #{kind} OR tags.kind = #{kind} "]}
	}
		
		
	def source
		case kind
		when "user"
			User.find_by_tag_id(self.id)
		when "image"
			Image.find_by_tag_id(self.id)
		when "comment"
			Comment.find(:first, :conditions => ['tag_id = ? ',self.id])
		else
			return self
		end
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
		tag = Tag.with_label(params[:label]).with_kind(params[:kind]).with_url(params[:url]).find(:first)
		tag = Tag.create(params) if tag.nil?
		tag
	end
	
	
	def connections(params = {})
		
	end
	
	def lists(params = {})
		List.created_by(params[:user] || nil).bound_to(self)
	end

	def properties
		data.scan(/#([\w]+)[\s]+([^#|\[|\]]+)*/).collect {|s| Nuniversal::LabelValue.new(s[0],s[1])}
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
		image
	end
	
	def tag_with(tags, params = {})
		tags.to_a.compact.each do |t|
			unless t.blank?
				@t = Tagging.create(:predicate => t, :taggable => self) rescue nil
			end
		end
		return @t
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

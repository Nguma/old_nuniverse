class List < ActiveRecord::Base

	belongs_to :tag, :class_name => 'Tag'
	belongs_to :creator, :class_name => 'User'
	#after_create :create_tag


	named_scope :bound_to, lambda { |bind| 
			bind.nil? ? {:conditions => 'tag_id IS NULL'} : {:conditions => ['tag_id = ?', bind.id]}
	}
	
	named_scope :created_by, lambda { |user| 
		{:conditions => ['creator_id = ?', user.id]}
	}
	
	named_scope :labeled, lambda { |label| 
		{:conditions => ['label = ?', label]}
	}
	
	named_scope :order_by, lambda { |order| 
		order.nil? ? {} : {:order => order }
	}
	
	# items
	# Extracts the tags from the list label, and performs a search against them as well as the full label
	# Filters are the following
	# users: list creator + users with permission
	# tags: inflected tags against Nuniverse::Kinds + list label
	# order: name, latest or votes
	# label: item label, used a lot for returning suggestions
	# page: page number
	# per_page: number of results per page
	def items(params = {})
		# tags =  Nuniverse::Kind.find_tags(self.label.downcase)
		tags = self.tag ? [self.tag.label.downcase, self.label.downcase.singularize] : [self.label.downcase.singularize] 
		users = params[:perspective] == "you" ? [self.creator] : [grantors, self.creator].flatten 
		subject = (self.tag && self.tag.kind != 'user') ? self.tag : nil

		Tagging.select(
			:users => [self.creator], 
			:tags => tags, 
			:order => params[:order], 
			:title => self.label,
			:label => params[:label] || nil,
			:page => params[:page], 
			:per_page => params[:per_page],
			:perspective => params[:perspective]
		)
		# Tagging.with_users().labeled_like(params[:label] || nil).with_subject(self.tag).with_tags(tags).order_by(params[:order]).paginate(:page => params[:page], :per_page => params[:per_page])
	end
	
	def permissions(params = {})
		Permission.find(:all, :conditions => ["tags = ? AND (grantor_id = ? OR granted_id = ?)", self.label, self.creator_id, self.creator_id])
		# Permission.for(self).paginate(params).collect {|c| c.user}
	end
	
	def grantors(params = {})
		return [] if self.label.blank?
		Permission.find(:all, :conditions => ["tags RLIKE ? AND granted_id = ?", "#{self.label}|#{self.label.pluralize}", self.creator_id]).collect {|c| c.grantor}
	end
	
	
	def self.find_or_create(params)
		l = List.find(:first, :conditions => params)
		return l unless l.nil?
		return List.create(params)		
	end
	
	def title
		self.tag.nil?  ? self.label.capitalize : "#{self.tag.label.capitalize} #{self.label.pluralize}"
	end
	
	def kind
		self.label.split(' ').last.downcase.singularize
	end
	
	def context
		self.label.gsub(/\s?\w+$/,'')
	end
	
	def uri_name
		self.title.downcase.gsub(' ','-')
	end
	
	protected
	def create_tag
		self.tag = Tag.create(
			:label => self.label,
			:kind => 'list'
		)
		self.save
	end
	

	
end
